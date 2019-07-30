import Foundation
import SwiftUI

/// Retrieves a mapping of the application state from the environment and provides it to a property in a SwiftUI view.
/// Use the `connect(updateWhen:mapState:)` method to first inject the state from a parent view.
/// ```
/// struct MyView : View {
///
///   @MappedState var todoList: TodoList
///
/// }
/// ```
@propertyWrapper
public struct MappedState<State> : DynamicProperty {

  @EnvironmentObject private var connection: StateConnection<State>

  private var _value: State!
  
  public var wrappedValue: State {
    get {
      self._value
    }
    set {
      self._value = newValue
    }
  }
  
  public var projectedValue: Binding<State> {
    Binding<State>(
      get: { self._value },
      set: { _ in }
    )
  }
  
  public var binding: Binding<State> {
    projectedValue
  }

  public init() {}
  
  public mutating func update() {
    /// It should retrieve at least one value, but there's a chance the view may still exist briefly when the state does not,
    /// so we only want to update if the state does exists.
    if let newValue = connection.getState() {
      self.wrappedValue = newValue
    }
  }

}
