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
  private unowned var store: Store<State>

  /// Send an action to the next middleware
  private var nextBlock: SendAction?

  private var doneBlock: (() -> Void)?

  /// Retrieves the latest state from the store.
  public var state: State {
    store.state
  }

  /// Emits after the specified action was sent to the store.
  public var didChange: AnyPublisher<Action, Never> {
    store.didChange
  }

  internal init(store: Store<State>, next: SendAction? = nil, done: (() -> Void)? = nil) {
    self.store = store
    self.nextBlock = next
    self.doneBlock = done
  }

  /// Send an action to the store.
  /// - Parameter action: The action to send
  public func send(_ action: Action) {
    store.send(action)
  }

  /// Use this in middleware to send an action to the next
  /// step in the pipeline. Outside of middleware, it does nothing.
  /// - Parameter action: The action to send
  public func next(_ action: Action) {
    nextBlock?(action)
  }

  /// Used by action plans to tell the store that a publisher has completed or cancelled its work.
  /// Only use this if the action plan is not returning a publisher or subscribing via ActionSubscriber.
  /// This is not needed by action plans that don't return a cancellable.
  public func done() {
    doneBlock?()
  }
}
