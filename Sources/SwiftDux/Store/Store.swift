import Foundation
import Combine

/// The primary container of an application's state.
///
/// The store both contains and mutates the state through a provided reducer as it's sent actions.
/// Use the didChange publisher to be notified of changes.
public final class Store<State> where State : StateType {

  /// The current state of the store. Use actions to mutate it.
  public private(set) var state: State
  
  private var reduceAction: SendAction!

  /// Subscribe for state changes. It emits the latest action sent to the store.
  public let didChange = PassthroughSubject<Action, Never>()

  /// Creates a new store for the given state and reducer
  ///
  /// - Parameters
  ///   - state: The initial state of the store. A typically use case is to restore a previous application session with a persisted state object.
  ///   - reducer: A reducer that will mutate the store's state as actions are dispatched to it.
  public init<R>(state: State, reducer: R, middleware: Middleware<State>...) where R : Reducer, R.State == State {
    self.state = state
    self.reduceAction = middleware.reversed().reduce(
      { [weak self] action in
        guard let self = self else { return }
        self.state = reducer.reduceAny(state: self.state, action: action)
        self.didChange.send(action)
      },
      { next, middleware in
        middleware(StoreProxy(store: self, next: next))
      }
    )
  }

}

extension Store : ActionDispatcher, Subscriber {

  /// Sends an action to the store to mutate its state.
  /// - Parameter action: The  action to mutate the state.
  /// - Returns: An optional publisher that can be used to know when the action has completed.
  public func send(_ action: Action) {
    switch action {
    case let action as ActionPlan<State>:
      self.send(actionPlan: action)
    case let action as PublishableActionPlan<State>:
      self.send(actionPlan: action)
    case let modifiedAction as ModifiedAction:
      reduceAction(modifiedAction.action)
      if let action = modifiedAction.previousActions.first {
        self.didChange.send(action)
      }
    default:
      reduceAction(action)
    }
  }
  
  /// Handles the sending of normal action plans.
  /// - Returns: An optional publisher that can be used to know when the action has completed.
  private func send(actionPlan: ActionPlan<State>) {
    actionPlan.run(StoreProxy(store: self))
  }

  /// Handles the sending of publishable action plans.
  /// - Returns: An optional publisher that can be used to know when the action has completed.
  public func send(actionPlan: PublishableActionPlan<State>) {
    actionPlan.run(StoreProxy(store: self)).compactMap { $0 }.subscribe(self)
  }
  
  /// Create a new `StoreActionDispatcher<_>` that acts as a proxy between the action sender and the store. It optionally allows actions to be
  /// modified or monitored.
  /// - Parameter modifyAction: A closure to modify the action before it continues up stream.
  public func proxy(modifyAction: ActionModifier? = nil) -> ActionDispatcher {
    return StoreActionDispatcher(
      upstream: self,
      modifyAction: modifyAction
    )
  }

}
