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
        store: self,
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
}

extension Store: ActionDispatcher {

  /// Sends an action to the store to mutate its state.
  /// - Parameter action: The  action to mutate the state.
  @inlinable public func send(_ action: Action) {
    if let action = action as? AnyActionPlan {
      send(actionPlan: action)
    } else {
      update(action)
    }
  }

  /// Handles the sending of normal action plans.
  @inlinable internal func send(actionPlan: AnyActionPlan) {
    var cancellable: AnyCancellable? = nil
    let storeProxy = StoreProxy(
      store: self,
      done: {
        cancellable?.cancel()
        cancellable = nil
      }
    )
    cancellable = actionPlan.runAny(storeProxy) { [storeProxy] in
      storeProxy.done()
    }
    didChangeSubject.send(actionPlan)
  }

  /// Create a new `ActionDispatcher` that acts as a proxy between the action sender and the store. It optionally allows actions to be
  /// modified or tracked.
  /// - Parameter modifyAction: An optional closure to modify the action before it continues up stream.
  /// - Returns: a new action dispatcher.
  @inlinable public func proxy(modifyAction: ActionModifier? = nil) -> ActionDispatcher {
    StoreProxy<State>(
      store: self,
      modifyAction: modifyAction
    )
  }
}
