import Combine
import Foundation

/// Creates a proxy of the store object for use by middleware.
///
/// Middleware may use the store proxy to retreive the current state, send actions,
/// continue to the next middleware, or subscribe to store changes. With the proxy,
/// middleware don't have to worry about retaining the store. Instead, the proxy provides
/// a safe API to access a weak reference to it.
public struct StoreProxy<State> where State: StateType {

  /// Subscribe to state changes.
  private var store: Store<State>

  /// Send an action to the next middleware
  private var nextBlock: SendAction?

  private var doneBlock: (() -> Void)?

  /// Retrieves the latest state from the store.
  public var state: State {
    store.state
  }

  public var didChange: AnyPublisher<Action, Never> {
    store.didChange
  }

  internal init(store: Store<State>, next: SendAction? = nil, done: (() -> Void)? = nil) {
    self.store = store
    self.nextBlock = next
    self.doneBlock = done
  }

  public func send(_ action: Action) {
    store.send(action)
  }

  public func next(_ action: Action) {
    nextBlock?(action)
  }

  public func done() {
    doneBlock?()
  }
}
