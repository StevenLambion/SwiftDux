import Combine
import Foundation

/// A closure that dispatches an action.
///
/// - Parameter action: Dispatches the given state synchronously.
public typealias SendAction = (Action) -> Void

/// A closure that can return a new action from a previous one. If no action is returned,
/// the original action is not sent.
public typealias ActionModifier = (Action) -> Action?

/// An object that dispatches actions to a store.
///
/// Once an action is sent, the sender shouldn't expect anything to occur. Instead, it should rely
/// solely on changes to the state of the application to respond.
public protocol ActionDispatcher {

  /// Sends an action to a reducer to mutate the state of the application.
  /// - Parameter action: An action to dispatch to the store.
  func send(_ action: Action)

  /// Create a new `ActionDispatcher` that acts as a proxy for the current one.
  ///
  /// Actions can be modified by both the new proxy and the original dispatcher it was created from.
  /// - Parameters
  ///   - modifyAction: An optional closure to modify the action before it continues up stream.
  ///   - sentAction: Called directly after an action was sent up stream.
  /// - Returns: a new action dispatcher.
  func proxy(modifyAction: ActionModifier?, sentAction: ((Action) -> Void)?) -> ActionDispatcher

}
