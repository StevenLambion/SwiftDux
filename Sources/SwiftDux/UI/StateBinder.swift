import Foundation
import SwiftUI

/// Binds a state to an action for use by controls that expect a two-way binding type such as TextFields.
///
/// ```
/// func map(state: AppState, binder: StateBinder) -> Props? {
///   Props(
///     todos: state.todos,
///     orderBy: binder.bind(state.orderBy) { TodoListAction.setOrderBy($0) }
///   )
/// }
/// ```
public struct StateBinder {

  internal var actionDispatcher: ActionDispatcher

  /// Create a binding between a given state and an action.
  ///
  /// - Parameters:
  ///   - get: The state to retrieve.
  ///   - dispatch: Given a new version of the state, it returns an action to dispatch.
  /// - Returns: A new Binding object.
  public func bind<T>(_ get: @autoclosure @escaping () -> T, dispatch: @escaping (T) -> Action) -> Binding<T> {
    Binding<T>(
      get: get,
      set: { self.actionDispatcher.send(dispatch($0)) }
    )
  }

}
