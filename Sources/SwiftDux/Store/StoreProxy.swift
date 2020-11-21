import Combine
import Foundation

/// Creates a proxy of the store object for use by middleware.
///
/// Middleware may use the store proxy to retreive the current state, send actions,
/// continue to the next middleware, or subscribe to store changes. With the proxy,
/// middleware don't have to worry about retaining the store. Instead, the proxy provides
/// a safe API to access a weak reference to it.
public struct StoreProxy<State>: StateStorable, ActionDispatcher {
  @usableFromInline internal var getState: () -> State

  /// Emits after the specified action was sent to the store.
  public var didChange: StorePublisher

  /// Send an action to the next middleware
  @usableFromInline
  internal var dispatcher: ActionDispatcher

  /// Retrieves the latest state from the store.
  public var state: State {
    getState()
  }

  @inlinable internal init(
    getState: @escaping () -> State,
    didChange: StorePublisher,
    dispatcher: ActionDispatcher
  ) {
    self.getState = getState
    self.didChange = didChange
    self.dispatcher = dispatcher
  }

  /// Sends an action to mutate the application state.
  ///
  /// - Parameter action: The action to send
  @inlinable public func send(_ action: Action) {
    dispatcher.send(action)
  }

  /// Sends an action to mutate the application state.
  ///
  /// - Parameter action: The action to send.
  /// - Returns: A cancellable object.
  @inlinable public func sendAsCancellable(_ action: Action) -> Cancellable {
    dispatcher.sendAsCancellable(action)
  }
}
