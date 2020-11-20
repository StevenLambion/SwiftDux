import Combine
import Foundation

/// An object that dispatches actions to a store.
///
/// Once an action is sent, the sender shouldn't expect anything to occur. Instead, it should rely
/// solely on changes to the state of the application to respond.
public protocol ActionDispatcher {

  /// Sends an action to mutate the application state.
  ///
  /// - Parameter action: An action to dispatch to the store.
  func send(_ action: Action)

  /// Sends a cancellable action to mutate the application state.
  ///
  /// - Parameter action: An action to dispatch to the store.
  /// - Returns: A cancellable object.
  func sendAsCancellable(_ action: Action) -> Cancellable
}

extension ActionDispatcher {

  /// Sends an action to mutate the application state.
  ///
  /// - Parameter action: An action to dispatch to the store
  @inlinable public func callAsFunction(_ action: Action) {
    send(action)
  }
}

