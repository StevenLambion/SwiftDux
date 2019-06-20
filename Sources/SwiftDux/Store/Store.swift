import Foundation
import Combine

/// The primary container of an application's state.
///
/// The store both contains and mutates the state through a provided reducer as it's sent actions.
/// Use the didChangeWithAction to be notified of changes.
public final class Store<State> where State : StateType {

  /// The current state of the store. Use actions to mutate it.
  public private(set) var state: State
  private let runReducer: (State, Action) -> State

  private let didChangeWithActionSubject = PassthroughSubject<Action, Never>()

  /// Subscribe to this publisher to be notified of state changes caused by a particular action.
  public let didChangeWithAction: AnyPublisher<Action, Never>

  /// Creates a new store for the given state and reducer
  ///
  /// - Parameters
  ///   - state: The initial state of the store. A typically use case is to restore a previous application session with a persisted state object.
  ///   - reducer: A reducer that will mutate the store's state as actions are dispatched to it.
  public init<R>(state: State, reducer: R) where R : Reducer, R.State == State {
    self.state = state
    self.runReducer = reducer.reduceAny
    self.didChangeWithAction = didChangeWithActionSubject.eraseToAnyPublisher()
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

extension Store : ActionDispatcher, Subscriber {

  /// Sends an action to the store to mutate its state.
  /// - Parameter action: The  action to mutate the state.
  @discardableResult
  public func send(_ action: Action) -> AnyPublisher<Void, Never> {
    if let action = action as? ActionPlan<State> {
      return self.send(actionPlan: action)
    } else if let action = action as? PublishableActionPlan<State> {
      return self.send(actionPlan: action)
    }
    self.state = runReducer(self.state, action)
    self.didChangeWithActionSubject.send(action)
    return Publishers.Just(()).eraseToAnyPublisher()
  }
  
  /// Handles the sending of normal action plans.
  @discardableResult
  private func send(actionPlan: ActionPlan<State>) -> AnyPublisher<Void, Never> {
    let dispatch: Dispatch = { [unowned self] in self.send($0) }
    let getState: GetState = { [unowned self] in self.state }
    actionPlan.body(dispatch, getState)
    return Publishers.Just(()).eraseToAnyPublisher()
  }
  
  /// Handles the sending of publishable action plans.
  @discardableResult
  public func send(actionPlan: PublishableActionPlan<State>) -> AnyPublisher<Void, Never> {
    let dispatch: Dispatch = { [unowned self] in self.send($0) }
    let getState: GetState = { [unowned self] in self.state }
    let publisher  = actionPlan.body(dispatch, getState).share()
    publisher.compactMap { $0 }.subscribe(self)
    return publisher.map { _ in () }.eraseToAnyPublisher()
  }

  /// Create a new `StoreActionDispatcher<_>` that acts as a proxy between the action sender and the store. It optionally allows actions to be
  /// modified or monitored.
  /// - Parameter modifyAction: A closure to modify the action before it continues up stream.
  public func dispatcher(modifyAction: StoreActionDispatcher<State>.ActionModifier? = nil) -> StoreActionDispatcher<State> {
    return StoreActionDispatcher(
      upstream: self,
      upstreamActionSubject: self.didChangeWithActionSubject,
      modifyAction: modifyAction
    )
  }

}
