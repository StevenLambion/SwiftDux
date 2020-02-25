import Combine
import Foundation

/// An object that dispatches actions to a store.
///
/// Once an action is sent, the sender shouldn't expect anything to occur. Instead, it should rely
/// solely on changes to the state of the application to respond.
public protocol ActionDispatcher {

  /// Sends an action to a reducer to mutate the state of the application.
  /// - Parameter action: An action to dispatch to the store.
  func send(_ action: Action)
}

extension ActionDispatcher {

  /// Sends an action to a reducer to mutate the state of the application.
  /// - Parameter action: An action to dispatch to the store
  @inlinable public func callAsFunction(_ action: Action) {
    send(action)
  }

  /// Send an action plan that returns a cancellable object.
  /// - Parameter actionPlan: The action
  /// - Returns: A cancellable to cancel the action.
  @inlinable public func sendAsCancellable<T>(_ actionPlan: ActionPlan<T>) -> AnyCancellable {
    actionPlan.sendAsCancellable(self)
  }
}
