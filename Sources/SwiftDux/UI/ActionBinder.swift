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
  @inlinable public func bind<T>(_ state: T, dispatch getAction: @escaping (T) -> Action?) -> ActionBinding<T> where T: Equatable {
    ActionBinding(
      value: state,
      isEqual: { state == $0 },
      set: {
        self.dispatch(getAction($0))
      }
    )
  }

  /// Create a function binding that dispatches an action.
  ///
  /// - Parameter getAction: A closure that returns an action to dispatch.
  /// - Returns: a function that dispatches the action.
  @inlinable public func bind(_ getAction: @escaping () -> Action?) -> ActionBinding<() -> Void> {
    .constant { self.dispatch(getAction()) }
  }

  /// Create a function binding that dispatches an action.
  ///
  /// - Parameter getAction: A closure that returns an action to dispatch.
  /// - Returns: a function that dispatches the action.
  @inlinable public func bind<P0>(_ getAction: @escaping (P0) -> Action?) -> ActionBinding<(P0) -> Void> {
    .constant { self.dispatch(getAction($0)) }
  }

  /// Create a function binding that dispatches an action.
  ///
  /// - Parameter getAction: A closure that returns an action to dispatch.
  /// - Returns: a function that dispatches the action.
  @inlinable public func bind<P0, P1>(_ getAction: @escaping (P0, P1) -> Action?) -> ActionBinding<(P0, P1) -> Void> {
    .constant { self.dispatch(getAction($0, $1)) }
  }

  /// Create a function binding that dispatches an action.
  ///
  /// - Parameter getAction: A closure that returns an action to dispatch.
  /// - Returns: a function that dispatches the action.
  @inlinable public func bind<P0, P1, P2>(
    _ getAction: @escaping (P0, P1, P2) -> Action?
  ) -> ActionBinding<(P0, P1, P2) -> Void> {
    .constant { self.dispatch(getAction($0, $1, $2)) }
  }

  /// Create a function binding that dispatches an action.
  ///
  /// - Parameter getAction: A closure that returns an action to dispatch.
  /// - Returns: a function that dispatches the action.
  @inlinable public func bind<P0, P1, P2, P3>(
    _ getAction: @escaping (P0, P1, P2, P3) -> Action?
  ) -> ActionBinding<(P0, P1, P2, P3) -> Void> {
    .constant { self.dispatch(getAction($0, $1, $2, $3)) }
  }

  /// Create a function binding that dispatches an action.
  ///
  /// - Parameter getAction: A closure that returns an action to dispatch.
  /// - Returns: a function that dispatches the action.
  @inlinable public func bind<P0, P1, P2, P3, P4>(
    _ getAction: @escaping (P0, P1, P2, P3, P4) -> Action?
  ) -> ActionBinding<(P0, P1, P2, P3, P4) -> Void> {
    .constant { self.dispatch(getAction($0, $1, $2, $3, $4)) }
  }

  /// Create a function binding that dispatches an action.
  ///
  /// - Parameter getAction: A closure that returns an action to dispatch.
  /// - Returns: a function that dispatches the action.
  @inlinable public func bind<P0, P1, P2, P3, P4, P5>(
    _ getAction: @escaping (P0, P1, P2, P3, P4, P5) -> Action?
  ) -> ActionBinding<(P0, P1, P2, P3, P4, P5) -> Void> {
    .constant { self.dispatch(getAction($0, $1, $2, $3, $4, $5)) }
  }

  @usableFromInline internal func dispatch(_ action: Action?) {
    guard let action = action else { return }
    actionDispatcher.send(action)
  }
}
