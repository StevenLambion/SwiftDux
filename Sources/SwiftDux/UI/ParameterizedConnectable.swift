import SwiftUI

/// Makes a view "connectable" to the application state using a parameter value.
public protocol ParameterizedConnectable {
  associatedtype Superstate: Equatable
  associatedtype Props: Equatable
  associatedtype Parameter

  /// Causes the view to be updated based on a dispatched action.
  /// 
  /// - Parameters
  ///   - action: The dispatched action
  ///   - parameter: A user defined parameter required to retrieve the state.
  /// - Returns: True if the view should update.
  func updateWhen(action: Action, with parameter: Parameter) -> Bool

  /// The method can return nil until the state becomes available. While it is nil, the view
  /// will not be rendered.
  /// - Parameters
  ///   - state: The superstate provided to the view from a superview.
  ///   - parameter: A user defined parameter required to retrieve the state.
  /// - Returns: The state if possible.
  func map(state: Superstate, with parameter: Parameter) -> Props?

  /// The method can return nil until the state becomes available. While it is nil, the view
  /// will not be rendered.
  /// - Parameters
  ///   - state: The superstate provided to the view from a superview.
  ///   - parameter: A user defined parameter required to retrieve the state.
  ///   - binder: Helper that creates Binding types beteen the state and a dispatcable action
  /// - Returns: The state if possible.
  func map(state: Superstate, with parameter: Parameter, binder: ActionBinder) -> Props?
}

extension ParameterizedConnectable {

  /// Default implementation disables updates by action.
  public func updateWhen(action: Action, with parameter: Parameter) -> Bool {
    guard let action = action as? NoUpdateAction else { return false }
    action.unused = true
    return true
  }

  /// Default implementation. Returns nil.
  public func map(state: Superstate, with parameter: Parameter) -> Props? {
    nil
  }

  /// Default implementation. Calls the other map function.
  public func map(state: Superstate, with parameter: Parameter, binder: ActionBinder) -> Props? {
    map(state: state, with: parameter)
  }
}

extension ParameterizedConnectable where Self: View {

  /// Connect the view to the application state via a provided parameter.
  ///
  /// - Parameter parameter: A view specific value required to connect the appropriate state.
  /// - Returns: The connected view.
  public func connect(with parameter: Parameter) -> some View {
    self.connect(
      mapState: { self.map(state: $0, with: parameter, binder: $1) }
    )
  }
}
