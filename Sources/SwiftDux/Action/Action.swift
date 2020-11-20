import Combine
import Foundation

/// A dispatchable action to update the application state.
/// ```
///   enum TodoList : Action {
///     case setItems(items: [TodoItem])
///     case addItem(withText: String)
///     case removeItems(at: IndexSet)
///     case moveItems(at: IndexSet, to: Int)
///   }
/// ```
public protocol Action {}

extension Action {

  /// Chains an array of actions to be dispatched next.
  ///
  /// - Parameter actions: An array of actions to chain together.
  /// - Returns: A composite action.
  @inlinable public func then(_ actions: [Action]) -> CompositeAction {
    if var action = self as? CompositeAction {
      action.actions += actions
      return action
    }
    return CompositeAction([self] + actions)
  }

  /// Chains an array of actions to be dispatched next.
  ///
  /// - Parameter actions: One or more actions to chain together.
  /// - Returns: A composite action.
  @inlinable public func then(_ actions: Action...) -> CompositeAction {
    then(actions)
  }

  /// Call the provided block next.
  ///
  /// - Parameter block: A block of code to execute once the previous action has completed.
  /// - Returns: A composite action.
  @inlinable public func then(_ block: @escaping ()->Void) -> CompositeAction {
    then(ActionPlan<Any> { _ in block() })
  }
}

/// A noop action used by reducers that may not have their own actions.
public struct EmptyAction: Action {

  public init() {}
}

/// A closure that dispatches an action.
///
/// - Parameter action: The action to dispatch.
public typealias SendAction = (Action)->Void

/// A closure that dispatches a cancellable action.
///
/// - Parameter action: The action to dispatch.
public typealias SendCancellableAction = (Action)->Cancellable
