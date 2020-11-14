import SwiftUI

/// Makes a view "connectable" to the application state.
///
/// This should not be used directly. Instead, use ConnectableView. This protocol isn't combined into ConnectableView due
/// to a possible bug in Swift that throws an invalid assocated type if Props isn't explicitly typealiased.
public protocol Connectable {

  associatedtype State
  associatedtype Props: Equatable

  /// Map a superstate to the state needed by the view using the provided parameter.
  ///
  /// The method can return nil until the state becomes available. While it is nil, the view
  /// will not be rendered.
  /// - Parameter state: The superstate provided to the view from a superview.
  /// - Returns: The state if possible.
  func map(state: State) -> Props?

  /// Map a superstate to the state needed by the view using the provided parameter.
  ///
  /// The method can return nil until the state becomes available. While it is nil, the view
  /// will not be rendered.
  /// - Parameters:
  ///   - state: The superstate provided to the view from a superview.
  ///   - binder: Helper that creates Binding types beteen the state and a dispatcable action
  /// - Returns: The state if possible.
  func map(state: State, binder: ActionBinder) -> Props?
}

extension Connectable {

  /// Default implementation. Returns nil.
  @inlinable public func map(state: State) -> Props? {
    nil
  }

  /// Default implementation. Calls the other map function.
  @inlinable public func map(state: State, binder: ActionBinder) -> Props? {
    map(state: state)
  }
}
