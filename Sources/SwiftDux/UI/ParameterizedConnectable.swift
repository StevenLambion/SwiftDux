import SwiftUI

/// Makes a view "connectable" to the application state using a parameter value.
public protocol ParameterizedConnectable {
  associatedtype Superstate
  associatedtype State
  associatedtype Parameter
  
  /// Return true to update the view's state after the action has been dispatched.
  /// - Parameter action: The dispatched action
  func updateWhen(action: Action) -> Bool
  
  /// Map a superstate to the state needed by the view using the provided parameter.
  /// - Parameters
  ///   - state: The superstate provided to the view from a superview.
  ///   - parameter: A user defined parameter required to retrieve the state.
  func map(state: Superstate, with parameter: Parameter) -> State?
  
}

extension ParameterizedConnectable where Self : View {
  
  /// Connect the view to the application state via a provided parameter
  /// - Parameter parameter: A view specific value required to connect the appropriate state.
  public func connect(with parameter: Parameter) -> some View {
    self.connect(updateWhen: self.updateWhen) { [map] in map($0, parameter) }
  }
  
}
