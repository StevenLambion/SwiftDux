import Combine
import Foundation

/// The primary container of an application's state.
///
/// The store both contains and mutates the state through a provided reducer as it's sent actions.
/// Use the didChange publisher to be notified of changes.
public final class Store<State> {

  /// The current state of the store. Use actions to mutate it.
  public private(set) var state: State

  /// Subscribe for state changes. It emits the latest action sent to the store.
  public let didChange: AnyPublisher<Action, Never>

  @usableFromInline
  internal var update: SendAction = { _ in }

  @usableFromInline
  internal let didChangeSubject = PassthroughSubject<Action, Never>()

  /// Creates a new store for the given state and reducer.
  ///
  /// - Parameters
  ///   - state: The initial state of the store. A typically use case is to restore a previous application session with a persisted state object.
  ///   - reducer: A reducer that will mutate the store's state as actions are dispatched to it.
  ///   - middleware: A middleware plugin.
  public init<R, M>(state: State, reducer: R, middleware: M) where R: Reducer, R.State == State, M: Middleware, M.State == State {
    let storeReducer = StoreReducer() + reducer
    self.state = state
    self.didChange = didChangeSubject.eraseToAnyPublisher()
    self.update = middleware(
      store: StoreProxy(
        getState: { [unowned self] in self.state },
        didChange: didChange,
        dispatcher: self,
        next: { [storeReducer, weak self] action in
          guard let self = self else { return }
          self.state = storeReducer(state: self.state, action: action)
          self.didChangeSubject.send(action)
        }
      )
    )
    update(StoreAction<State>.prepare)
  }

  /// Creates a new store for the given state and reducer.
  ///
  /// - Parameters
  ///   - state: The initial state of the store. A typically use case is to restore a previous application session with a persisted state object.
  ///   - reducer: A reducer that will mutate the store's state as actions are dispatched to it.
  public convenience init<R>(state: State, reducer: R) where R: Reducer, R.State == State {
    self.init(state: state, reducer: reducer, middleware: NoopMiddleware())
  }

  /// Create a proxy of the store for a given type that it adheres to.
  /// - Parameters:
  ///   - stateType: The type of state for the proxy. This must be a type that the store adheres to.
  ///   - done: A closure called with an async action has completed.
  /// - Returns: A proxy object if the state type matches, otherwise nil.
  @inlinable public func proxy<T>(for stateType: T.Type, done: (() -> Void)? = nil) -> StoreProxy<T>? {
    guard State.self is T.Type else { return nil }
    return StoreProxy<T>(
      getState: { [unowned self] in self.state as! T },
      didChange: didChange,
      dispatcher: self,
      done: done
    )
  }
}

extension Store: ActionDispatcher {

  /// Sends an action to the store to mutate its state.
  /// - Parameter action: The  action to mutate the state.
  @inlinable public func send(_ action: Action) {
    if let action = action as? RunnableAction {
      _ = action.run(store: self)
    } else {
      update(action)
    }
  }
}
