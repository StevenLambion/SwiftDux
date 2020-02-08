import Combine
import Foundation

/// The primary container of an application's state.
///
/// The store both contains and mutates the state through a provided reducer as it's sent actions.
/// Use the didChange publisher to be notified of changes.
public final class Store<State> where State: StateType {

  /// The current state of the store. Use actions to mutate it.
  public private(set) var state: State

  /// Subscribe for state changes. It emits the latest action sent to the store.
  public let didChange: AnyPublisher<Action, Never>

  private var reduceAction: SendAction = { _ in }

  internal let didChangeSubject = PassthroughSubject<Action, Never>()

  // swift-format-disable: ValidateDocumentationComments

  /// Creates a new store for the given state and reducer
  ///
  /// - Parameters
  ///   - state: The initial state of the store. A typically use case is to restore a previous application session with a persisted state object.
  ///   - reducer: A reducer that will mutate the store's state as actions are dispatched to it.
  ///   - middleware: One or more middleware plugins
  public init<R>(state: State, reducer: R, middleware: [Middleware] = []) where R: Reducer, R.State == State {
    let storeReducer = StoreReducer(reducer)
    self.state = state
    self.didChange = didChangeSubject.eraseToAnyPublisher()
    self.reduceAction = middleware.reversed().reduce(
      { [weak self] action in
        guard let self = self else { return }
        self.state = storeReducer.reduceAny(state: self.state, action: action)
        self.didChangeSubject.send(action)
      },
      { next, middleware in
        middleware.compile(store: StoreProxy(store: self, next: next))
      }
    )
    self.reduceAction(StoreAction<State>.prepare)
  }

  // swift-format-enable: ValidateDocumentationComments

}

extension Store: ActionDispatcher {

  /// Sends an action to the store to mutate its state.
  /// - Parameter action: The  action to mutate the state.
  public func send(_ action: Action) {
    if let action = action as? ActionPlan<State> {
      send(actionPlan: action)
    } else {
      reduceAction(action)
    }
  }

  /// Handles the sending of normal action plans.
  private func send(actionPlan: ActionPlan<State>) {
    var cancellable: AnyCancellable? = nil
    let storeProxy = StoreProxy(
      store: self,
      done: {
        cancellable?.cancel()
        cancellable = nil
      }
    )
    cancellable = actionPlan.run(storeProxy) { [storeProxy] in
      storeProxy.done()
    }
    didChangeSubject.send(actionPlan)
  }

  /// Create a new `ActionDispatcher` that acts as a proxy between the action sender and the store. It optionally allows actions to be
  /// modified or tracked.
  /// - Parameter modifyAction: An optional closure to modify the action before it continues up stream.
  /// - Returns: a new action dispatcher.
  public func proxy(modifyAction: ActionModifier? = nil) -> ActionDispatcher {
    StoreProxy<State>(
      store: self,
      modifyAction: modifyAction
    )
  }
}
