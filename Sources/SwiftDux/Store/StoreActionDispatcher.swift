import Combine
import Foundation

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
///       .modifyActions(self.routeChildActions)
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
internal final class StoreActionDispatcher<State>: ActionDispatcher where State: StateType {

  private let upstream: Store<State>
  private let modifyAction: ActionModifier?
  private let sentAction: ((Action) -> Void)?

  /// Creates a new `StoreActionDispatcher` for the upstream store.
  /// - Parameters
  ///   - upstream: The store object.
  ///   - modifyAction: Modifies a dispatched action before sending it off to the upstream store.
  ///   - sentAction: Callback fired when an action was sent by this dispatcher.
  init(upstream: Store<State>, modifyAction: ActionModifier? = nil, sentAction: ((Action) -> Void)? = nil) {
    self.upstream = upstream
    self.modifyAction = modifyAction
    self.sentAction = sentAction
  }

  /// Sends an action to a reducer to mutate the state of the application.
  /// - Parameter action: An action to dispatch to the store.
  func send(_ action: Action) {
    if let action = action as? ActionPlan<State> {
      send(actionPlan: action)
    } else {
      if let modifyAction = modifyAction, let newAction = modifyAction(action) {
        upstream.send(ModifiedAction(action: newAction, previousAction: action))
      } else {
        upstream.send(action)
      }
      sentAction?(action)
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
  private func send(actionPlan: ActionPlan<State>) {
    var cancellable: AnyCancellable?
    let storeProxy = StoreProxy(
      store: upstream,
      done: {
        cancellable?.cancel()
        cancellable = nil
      }
    )
    cancellable = actionPlan.run(storeProxy) { [storeProxy] in
      storeProxy.done()
    }
    upstream.didChangeSubject.send(actionPlan)
    sentAction?(actionPlan)
  }

}

extension StoreActionDispatcher {

  /// Create a new `ActionDispatcher` that acts as a proxy of the current one. Actions will be modified
  /// by both the new proxy and the original dispatcher it was created from.
  /// - Parameters
  ///   - modifyAction: An optional closure to modify the action before it continues up stream.
  ///   - sentAction: Called directly after an action was sent up stream.
  /// - Returns: a new action dispatcher.
  func proxy(modifyAction: ActionModifier? = nil, sentAction: ((Action) -> Void)? = nil) -> ActionDispatcher {
    let upstreamModifyAction = self.modifyAction
    var modifyActionWrapper: ActionModifier? = nil
    if let modifyAction = modifyAction {
      modifyActionWrapper = {
        if let action = modifyAction($0) {
          return upstreamModifyAction?(action) ?? action
        }
        return nil
      }
    } else {
      modifyActionWrapper = upstreamModifyAction
    }
    return StoreActionDispatcher<State>(
      upstream: self.upstream,
      modifyAction: modifyActionWrapper,
      sentAction: sentAction
    )
  }

}
