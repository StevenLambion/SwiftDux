import Combine
import Foundation

/// A dispatchable action sent to a `Store<_>` to modify the state.
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
    CompositeAction([self] + actions)
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
  @inlinable public func then(_ block: @escaping () -> Void) -> CompositeAction {
    then(ActionPlan<Any> { _ in block() })
  }
}

@inlinable public func + (lhs: Action, rhs: Action) -> CompositeAction {
  if var lhs = lhs as? CompositeAction {
    lhs.actions.append(rhs)
    return lhs
  }
  return CompositeAction([lhs, rhs])
}

/// A noop action used by reducers that may not have their own actions.
public struct EmptyAction: Action {

  public init() {}
}

/// A closure that dispatches an action.
///
/// - Parameter action: The action to dispatch.
public typealias SendAction = (Action) -> Void
