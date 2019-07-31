import SwiftUI

/// Makes a view "connectable" to the application state.
public protocol Connectable {
  associatedtype Superstate
  associatedtype State
  
  /// Return true to update the view's state after the action has been dispatched.
  /// - Parameter action: The dispatched action
  func updateWhen(action: Action) -> Bool
  
  /// Map a superstate to the state needed by the view using the provided parameter.
  /// - Parameter state: The superstate provided to the view from a superview.
  func map(state: Superstate) -> State?
  
}

extension Connectable where Self : View {
  
  /// Connect the view to the application state
  public func connect() -> some View {
    self.connect(updateWhen: self.updateWhen, mapState: self.map)
  }
  
}
