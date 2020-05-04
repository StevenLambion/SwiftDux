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
  @EnvironmentObject private var storeWrapper: StoreWrapper<State>

  public var wrappedValue: State {
    storeWrapper.store.state
  }

  public init() {}
}
