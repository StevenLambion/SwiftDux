import Combine
import Foundation

/// An action that performs external logic outside of a reducer.
public protocol RunnableAction: Action {

  /// When the action is dispatched to a store, this method will be called to handle
  /// any logic by the action.
  ///
  /// - Parameter store: The store that the action has been dispatched to.
  /// - Returns: A cancellable object.
  func run<T>(store: Store<T>) -> AnyPublisher<Action, Never>
}
