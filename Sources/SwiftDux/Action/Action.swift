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

/// A noop action used by reducers that may not have their own actions.
public struct EmptyAction: Action {}
