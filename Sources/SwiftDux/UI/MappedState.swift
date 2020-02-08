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
public struct MappedState<State>: DynamicProperty where State: Equatable {
  @EnvironmentObject private var connection: StateConnection<State>

  public var wrappedValue: State {
    guard let state = connection.state else {
      fatalError("State was not connected before using @MappedState")
    }
    return state
  }

  public init() {}
}
