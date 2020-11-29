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
    self.state = state
    self.reduce = compile(middleware: middleware + ReducerMiddleware(reducer: reducer) { [weak self] in self?.state = $0 })
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

  private func compile<M>(middleware: M) -> SendAction where M: Middleware, M.State == State {
    middleware(
      store: StoreProxy(
        getState: { [unowned self] in self.state },
        didChange: didChange,
        dispatcher: ActionDispatcherProxy(
          send: { [unowned self] in self.send($0) },
          sendAsCancellable: { [unowned self] in self.sendAsCancellable($0) }
        )
      )
    )
  }
}

extension Store: ActionDispatcher {

  /// Sends an action to mutate the state.
  ///
  /// - Parameter action: The  action to perform.
  @inlinable public func send(_ action: Action) {
    if let action = action as? RunnableAction {
      reduceRunnableAction(action)
    } else {
      reduce(action)
    }
  }

  /// Sends an action to mutate the state.
  ///
  /// - Parameter action: The  action to perform.
  /// - Returns: A cancellable object.
  @inlinable public func sendAsCancellable(_ action: Action) -> Cancellable {
    if let action = action as? RunnableAction {
      return action.run(store: self.proxy()).send(to: self)
    }
    return Just(action).send(to: self)
  }

  /// Reduces a runnable action.
  ///
  /// - Parameter action: The  action to perform.
  @usableFromInline internal func reduceRunnableAction(_ action: RunnableAction) {
    var cancellable: AnyCancellable? = nil

    cancellable = action.run(store: self.proxy())
      .handleEvents(receiveCompletion: { _ in
        cancellable?.cancel()
        cancellable = nil
      })
      .send(to: self)
  }
}
