import Foundation
import Combine

/// A dispatcher tied to an upstream `Store<_>` object. This is useful to proxy dispatched actions.
///
/// Use the `Store<_>.dispatcher(modifyAction:)` or the `StoreActionDispatcher<_>.proxy(modifyAction:)`
/// methods to create a new `StoreActionDispatcher`.
///
/// ```
/// struct ParentView : View {
///
///   var body: some View {
///     ChildView()
///       .connected()
///       .proxyDispatch(for: AppState.self, modifyAction: self.routeChildActions)
///   }
///
///   func routeChildActions(action: Action) -> Action? {
///     if let action = $0 as? ChildAction {
///       return ParentAction.routeChildAction(action, forId: parentId)
///     }
///     return action // Send original action.
///   }
/// }
/// ```
public final class StoreActionDispatcher<State> : ActionPlanDispatcher where State : StateType {
  
  /// A closure that can return a new action from a previous one. If no action is returned,
  /// the original action is not sent.
  public typealias ActionModifier = (Action) -> Action?
  
  private let upstream: Store<State>
  private let upstreamActionSubject: PassthroughSubject<Action, Never>
  private let modifyAction: ActionModifier?
  
  /// Creates a new `StoreActionDispatcher` for the upstream store.
  /// - Parameters
  ///   - upstream: The store object.
  ///   - upstreamActionSubject: A subject used to fire actions that have been modified by the dispatcher. Typically this is provided from the upstream store
  ///   - modifyAction: Modifies a dispatched action before sending it off to the upstream store.
  public init(upstream: Store<State>, upstreamActionSubject: PassthroughSubject<Action, Never>, modifyAction: ActionModifier? = nil) {
    self.upstream = upstream
    self.upstreamActionSubject = upstreamActionSubject
    self.modifyAction = modifyAction
  }
  
  /// Sends an action to a reducer to mutate the state of the application.
  /// - Parameter action: An action to dispatch to the store.
  public func send(_ action: Action) {
    if let modifyAction = modifyAction, let newAction = modifyAction(action) {
      upstream.send(newAction)
      upstreamActionSubject.send(action)
    } else {
      upstream.send(action)
    }
  }
  
  /// Sends a self-contained action plan to mutate the application's state. Action plans are typically
  /// used when multiple actions must be dispatched or there's asynchronous actions that must be
  /// performed.
  ///
  /// The dispatching of actions should always be done on the main thread. Action plans can be used
  /// to offload to other threads to perform complex workflows before pushing the changes into the state
  /// on the main thread.
  /// - Parameter actionPlan: The action to dispatch
  public func send(_ actionPlan: ActionPlan<State>) {
    let dispatch: ActionPlanDispatch = { [unowned self] in self.send($0) }
    let getState: GetState = { [unowned upstream] in upstream.state }
    actionPlan(dispatch, getState)
  }
  
  /// Sends a self contained action plan that a dispatcher can subscribe to. The plan may send
  /// actions directly to the store object, or it can opt to publish them. In most cases, there should be
  /// at least one primary action that is published.
  ///
  /// The caller to the method will recieve an optional publisher to notify it that an action was sent. It can
  /// also be used to signify the completion of the action plan to allow the trigger of external events or side
  /// effects that are unable to be performed from at the state level.
  /// - Parameter actionPlan: An action plan that optionally publishes actions to be dispatched.
  /// - Returns: A void publisher that notifies subscribers when an action has been dispatched or when the action plan has completed.
  public func send(_ actionPlan: PublishableActionPlan<State>) -> AnyPublisher<Void, Never> {
    let dispatch: ActionPlanDispatch = { [unowned self] in self.send($0) }
    let getState: GetState = { [unowned upstream] in upstream.state }
    let publisher  = actionPlan(dispatch, getState)
    publisher.compactMap { $0 }.subscribe(self)
    return publisher.map { _ in () }.eraseToAnyPublisher()
  }
  
}

extension StoreActionDispatcher {
  
  /// Create a new `StoreActionDispatcher<_>` that proxies off of the current one. Actions will be modified
  /// by both the new proxy and the original dispatcher it was created from.
  /// - Parameter modifyAction: A closure to modify the action before it continues up stream.
  public func proxy(modifyAction: ActionModifier? = nil) -> StoreActionDispatcher<State> {
    let upstreamModifyAction = self.modifyAction
    var modifyActionWrapper = upstreamModifyAction
    if let modifyAction = modifyAction {
      modifyActionWrapper = {
        if let action = modifyAction($0) {
          return upstreamModifyAction?(action) ?? action
        }
        return nil
      }
    }
    return StoreActionDispatcher<State>(
      upstream: self.upstream,
      upstreamActionSubject: self.upstreamActionSubject,
      modifyAction: modifyActionWrapper
    )
  }
  
}
