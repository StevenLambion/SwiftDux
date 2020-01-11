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
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
public struct MappedState<State>: DynamicProperty {

  @EnvironmentObject private var connection: StateConnection<State>

  // Needed by SwiftUI in case StateBinder is used. This attaches the required
  // subscriptions.
  @Environment(\.actionDispatcher) private var actionDispatcher: ActionDispatcher

  public var wrappedValue: State {
    connection.latestState!
  }

  public var projectedValue: Binding<State> {
    Binding<State>(
      get: { self.wrappedValue },
      set: { _ in }
    )
  }

  public var binding: Binding<State> {
    projectedValue
  }

  public init() {}

}
