import Foundation
import Combine

/// The primary container of an application's state.
///
/// The store both contains and mutates the state through a provided reducer as it's sent actions.
/// Use the didChange publisher to be notified of changes.
public final class Store<State> where State : StateType {

  /// The current state of the store. Use actions to mutate it.
  public private(set) var state: State
  private let runReducer: (State, Action) -> State

  private let didChangeWithActionSubject = PassthroughSubject<Action, Never>()

  /// Subscribe to this publisher to be notified of state changes caused by a particular action.
  public let didChange: AnyPublisher<Action, Never>

  /// Creates a new store for the given state and reducer
  ///
  /// - Parameters
  ///   - state: The initial state of the store. A typically use case is to restore a previous application session with a persisted state object.
  ///   - reducer: A reducer that will mutate the store's state as actions are dispatched to it.
  public init<R>(state: State, reducer: R) where R : Reducer, R.State == State {
    self.state = state
    self.runReducer = reducer.reduceAny
    self.didChange = didChangeWithActionSubject
      .eraseToAnyPublisher()
  }

}

extension Store : ActionDispatcher, Subscriber {

  /// Sends an action to the store to mutate its state.
  /// - Parameter action: The  action to mutate the state.
  /// - Returns: An optional publisher that can be used to know when the action has completed.
  @discardableResult
  public func send(_ action: Action) -> AnyPublisher<Void, Never> {
    switch action {
    case let action as ActionPlan<State>:
      return self.send(actionPlan: action)
    case let action as PublishableActionPlan<State>:
      return self.send(actionPlan: action)
    case let modifiedAction as ModifiedAction:
      self.state = runReducer(self.state, modifiedAction.action)
      modifiedAction.previousActions.forEach {
        self.didChangeWithActionSubject.send($0)
      }
      self.didChangeWithActionSubject.send(modifiedAction.action)
    default:
      self.state = runReducer(self.state, action)
      self.didChangeWithActionSubject.send(action)
    }
    return Just(()).eraseToAnyPublisher()
  }

  /// Handles the sending of normal action plans.
  /// - Returns: An optional publisher that can be used to know when the action has completed.
  @discardableResult
  private func send(actionPlan: ActionPlan<State>) -> AnyPublisher<Void, Never> {
    let send: SendAction = { [unowned self] in self.send($0) }
    let getState: GetState = { [unowned self] in self.state }
    actionPlan.run(send: send, getState: getState)
    return Just(()).eraseToAnyPublisher()
  }

  /// Handles the sending of publishable action plans.
  /// - Returns: An optional publisher that can be used to know when the action has completed.
  @discardableResult
  public func send(actionPlan: PublishableActionPlan<State>) -> AnyPublisher<Void, Never> {
    let send: SendAction = { [unowned self] in self.send($0) }
    let getState: GetState = { [unowned self] in self.state }
    let publisher  = actionPlan.run(send: send, getState: getState).share()
    publisher.compactMap { $0 }.subscribe(self)
    return publisher.map { _ in () }.eraseToAnyPublisher()
  }

  /// Create a new `StoreActionDispatcher<_>` that acts as a proxy between the action sender and the store. It optionally allows actions to be
  /// modified or monitored.
  /// - Parameter modifyAction: A closure to modify the action before it continues up stream.
  public func proxy(modifyAction: ActionModifier? = nil) -> ActionDispatcher {
    return StoreActionDispatcher(
      upstream: self,
      upstreamActionSubject: self.didChangeWithActionSubject,
      modifyAction: modifyAction
    )
  }

}
