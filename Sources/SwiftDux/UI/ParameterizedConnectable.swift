import SwiftUI

/// Makes a view "connectable" to the application state using a parameter value.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol ParameterizedConnectable {
  associatedtype Superstate
  associatedtype State
  associatedtype Parameter
  
  /// Causes the view to be updated based on a dispatched action.
  /// - Parameter action: The dispatched action
  func updateWhen(action: Action, with parameter: Parameter) -> Bool
  
  /// Map a superstate to the state needed by the view using the provided parameter.
  /// - Parameters
  ///   - state: The superstate provided to the view from a superview.
  ///   - parameter: A user defined parameter required to retrieve the state.
  func map(state: Superstate, with parameter: Parameter) -> State?
  
}

extension ParameterizedConnectable {

  /// Default implementation disables updates by action.
  public func updateWhen(action: Action, with parameter: Parameter) -> Bool {
    action is NoUpdateAction
  }
  
}

extension ParameterizedConnectable where Self : View {
  
  /// Connect the view to the application state via a provided parameter
  /// - Parameter parameter: A view specific value required to connect the appropriate state.
  public func connect(with parameter: Parameter) -> some View {
    self.connect(updateWhen: { [updateWhen] in updateWhen($0, parameter) }) { [map] in map($0, parameter) }
  }
  
}
