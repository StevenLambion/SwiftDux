import Foundation
import Combine

/// A type of object that can be used as storage of state.
public protocol StoreType : class, ActionPlanDispatcher {
  
  /// The current state of the store
  var state: State { get }
  
  /// Publishes actions that have modified the state.
  var didChangeWithAction: AnyPublisher<Action, Never> { get }

}

extension StoreType {
  
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
    let getState: GetState = { [unowned self] in self.state }
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
  @discardableResult
  public func send(_ actionPlan: PublishableActionPlan<State>) -> AnyPublisher<Void, Never> {
    let dispatch: ActionPlanDispatch = { [unowned self] in self.send($0) }
    let getState: GetState = { [unowned self] in self.state }
    let publisher  = actionPlan(dispatch, getState).share()
    publisher.compactMap { $0 }.subscribe(self)
    return publisher.map { _ in () }.eraseToAnyPublisher()
  }
  
  /// Subscribe to the store to be notified when a type of action is dispatched.
  /// - Parameter typeOfAction: The type of action required to emit a notification.
  public func on<A>(typeOfAction: A.Type) -> AnyPublisher<Void, Never> where A : Action {
    return didChangeWithAction.filter { $0 is A }.map { _ in () }.eraseToAnyPublisher()
  }
  
  /// Subscribe to the store to map its state when an action is dispatched. The publisher only fires when the output type has changed.
  /// - Parameters
  ///   - typeOfAction: The type of action required to emit a notification.
  ///   - mapState: A closure that maps the state to a new type.
  public func on<A,T>(typeOfAction: A.Type, mapState: @escaping (State)->T) -> AnyPublisher<T, Never> where A : Action, T : Equatable {
    self.on(typeOfAction: typeOfAction)
      .map { [unowned self] _ in mapState(self.state) }
      .removeDuplicates()
      .eraseToAnyPublisher()
  }
  
  /// Map the state of the store to a new object when it changes. It emits a new object only when there's a change.
  /// Because of this, it requires that the object adhere to the `Equatable` protocol.
  /// - Parameter mapState: A closure that maps the state to an object.
  public func mapState<T>(_ mapState: @escaping (State) -> T) -> AnyPublisher<T, Never> where T : Equatable {
    return didChangeWithAction
      .map { [unowned self] _ in mapState(self.state) }
      .removeDuplicates()
      .eraseToAnyPublisher()
  }
  
}
