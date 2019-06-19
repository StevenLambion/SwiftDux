import Foundation

/// Specifies a type as a dispatchable action.
///
/// Typically this is done with enum types, however,  it could be added to protocols or structs if
/// a more complex solution is needed.
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
public struct EmptyAction : Action {}