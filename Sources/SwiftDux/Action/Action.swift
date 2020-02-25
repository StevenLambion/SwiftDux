import Combine
import Foundation

/// A dispatchable action that provides information to a reducer to mutate the state of the application.
///
/// Typically this is done with enum types, however,  it could be added to protocols or structs if
/// a more complex solution is needed. Structs are also a could choice if actions need to be codable.
///
/// ```
///   enum TodoList : Action {
///     case setItems(items: [TodoItem])
///     case addItem(withText: String)
///     case removeItems(at: IndexSet)
///     case moveItems(at: IndexSet, to: Int)
///   }
///
///   // You can also create new protocols that represent an entire feature's actions.
///   // This can allows views to update off of a granular action or any actions
///   // of a given feature.
///   protocol FeatureLevelAction : Action {}
///
///   enum SubfeatureAction: FeatureLevelAction {
///     ...
///   }
/// ```
public protocol Action {}

/// A special kind of action that performs internal logic outside of a reducer.
///
/// An ActionPlan<_> is a concrete type of RunnbableAction, and is good enough
/// for most cases.
public protocol RunnableAction: Action {

  /// When the action is dispatched to a store, this method will be called to handle
  /// any logic by the action.
  /// - Parameter store: The store that the action has been dispatched to.
  /// - Returns: An optional cancellable.
  func run<T>(store: Store<T>) -> AnyCancellable?

}

/// A noop action used by reducers that may not have their own actions.
public struct EmptyAction: Action {

  public init() {}
}

/// A closure that dispatches an action.
///
/// - Parameter action: Dispatches the given action synchronously.
public typealias SendAction = (Action) -> Void
