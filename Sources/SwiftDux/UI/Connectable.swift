import SwiftUI

/// Makes a view "connectable" to the application state.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol Connectable {
  associatedtype Superstate
  associatedtype State

  /// Causes the view to be updated based on a dispatched action.
  /// - Parameter action: The dispatched action
  func updateWhen(action: Action) -> Bool

  /// Map a superstate to the state needed by the view using the provided parameter.
  /// - Parameter state: The superstate provided to the view from a superview.
  func map(state: Superstate) -> State?

}

extension Connectable {

  /// Default implementation disables updates by action.
  public func updateWhen(action: Action) -> Bool {
    action is NoUpdateAction
  }

}

extension Connectable where Self: View {

  /// Connect the view to the application state
  public func connect() -> some View {
    self.connect(updateWhen: self.updateWhen, mapState: self.map)
  }

}
