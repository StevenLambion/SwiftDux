import Foundation
import SwiftUI

/// Binds a state to a setter based action for use by controls that expect a two-way binding value such as TextFields.
/// This is useful for simple actions that are expected to be dispatched many times a second. It should be avoided by any
/// complicated or asynchronous actions.
///
/// ```
/// func map(state: AppState, binder: StateBinder) -> Props? {
///   Props(
///     todos: state.todos,
///     orderBy: binder.bind(state.orderBy) { TodoListAction.setOrderBy($0) }
///   )
/// }
/// ```
public struct ActionBinder {
  @usableFromInline
  internal var actionDispatcher: ActionDispatcher

  /// Create a binding between a given state and an action.
  ///
  /// - Parameters:
  ///   - state: The state to retrieve.
  ///   - getAction: Given a new version of the state, it returns an action to dispatch.
  /// - Returns: A new Binding object.
  @inlinable public func bind<T>(_ state: T, dispatch getAction: @escaping (T) -> Action?) -> ActionBinding<T> {
    ActionBinding(
      value: state,
      set: { [actionDispatcher] in
        guard let action = getAction($0) else { return }
        actionDispatcher.send(action)
      }
    )
  }
}

@available(*, deprecated, renamed: "ActionBinder")
public typealias StateBinder = ActionBinder
