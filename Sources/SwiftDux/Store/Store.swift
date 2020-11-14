import Combine
import Foundation

/// Stores and mutates the state of an application.
public final class Store<State>: StateStorable {

  /// The current state of the store.
  public private(set) var state: State {
    didSet { didChange.send() }
  }

  /// Publishes when the state has changed.
  public let didChange = StorePublisher()

  @usableFromInline
  internal var reduce: SendAction = { _ in }

  /// Initiates a new store for the given state and reducer.
  ///
  /// - Parameters
  ///   - state: The initial state of the store.
  ///   - reducer: A reducer that mutates the state as actions are dispatched to it.
  ///   - middleware: A middleware plugin.
  public init<R, M>(state: State, reducer: R, middleware: M) where R: Reducer, R.State == State, M: Middleware, M.State == State {
    let storeReducer = StoreReducer(rootReducer: reducer)
    self.state = state
    self.reduce = middleware(
      store: StoreProxy(
        getState: { [unowned self] in self.state },
        didChange: didChange,
        dispatcher: self,
        next: { [weak self] action in
          guard let self = self else { return }
          self.state = storeReducer(state: self.state, action: action)
        }
      )
    )
    send(StoreAction<State>.prepare)
  }

  /// Initiates a new store for the given state and reducer.
  ///
  /// - Parameters
  ///   - state: The initial state of the store.
  ///   - reducer: A reducer that mutates the state as actions are dispatched to it.
  public convenience init<R>(state: State, reducer: R) where R: Reducer, R.State == State {
    self.init(state: state, reducer: reducer, middleware: NoopMiddleware())
  }

  /// Create a proxy of the store for a given type or protocol.
  ///
  /// - Parameters:
  ///   - stateType: The type of state for the proxy. This must be a type that the store adheres to.
  ///   - done: A closure called with an async action has completed.
  /// - Returns: A proxy object if the state type matches, otherwise nil.
  @inlinable public func proxy<T>(for stateType: T.Type, done: (() -> Void)? = nil) -> StoreProxy<T>? {
    guard state is T else { return nil }
    return StoreProxy<T>(
      getState: { self.state as! T },
      didChange: didChange,
      dispatcher: self,
      done: done
    )
  }
}

extension Store: ActionDispatcher {

  /// Sends an action to mutate the state.
  ///
  /// - Parameter action: The  action to perform.
  @inlinable public func send(_ action: Action) {
    if let action = action as? RunnableAction {
      _ = action.run(store: self)
    } else {
      reduce(action)
    }
  }
}
