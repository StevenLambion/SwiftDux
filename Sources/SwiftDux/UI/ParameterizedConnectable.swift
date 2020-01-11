import SwiftUI

/// Makes a view "connectable" to the application state using a parameter value.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol ParameterizedConnectable {
  associatedtype Superstate
  associatedtype State
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
  func map(state: Superstate, with parameter: Parameter) -> State?

  /// The method can return nil until the state becomes available. While it is nil, the view
  /// will not be rendered.
  /// - Parameters
  ///   - state: The superstate provided to the view from a superview.
  ///   - parameter: A user defined parameter required to retrieve the state.
  ///   - binder: Helper that creates Binding types beteen the state and a dispatcable action
  /// - Returns: The state if possible.
  func map(state: Superstate, with parameter: Parameter, binder: StateBinder) -> State?

}

extension ParameterizedConnectable {

  /// Default implementation disables updates by action.
  public func updateWhen(action: Action, with parameter: Parameter) -> Bool {
    action is NoUpdateAction
  }

  /// Default implementation. Returns nil.
  public func map(state: Superstate, with parameter: Parameter) -> State? {
    nil
  }

  /// Default implementation. Calls the other map function.
  public func map(state: Superstate, with parameter: Parameter, binder: StateBinder) -> State? {
    map(state: state, with: parameter)
  }

}

extension ParameterizedConnectable where Self: View {

  // swift-format-disable: ValidateDocumentationComments

  /// Connect the view to the application state via a provided parameter
  ///
  /// - Parameter parameter: A view specific value required to connect the appropriate state.
  /// - Returns: The connected view.
  public func connect(with parameter: Parameter) -> some View {
    self.connect(
      updateWhen: { [updateWhen] in updateWhen($0, parameter) },
      mapState: { self.map(state: $0, with: parameter, binder: $1) }
    )
  }

  // swift-format-enable: ValidateDocumentationComments

}
