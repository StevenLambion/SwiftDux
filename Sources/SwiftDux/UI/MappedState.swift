import Foundation
import SwiftUI

/// Retrieves a mapping of the application state from the environment and provides it to a property in a SwiftUI view.
/// ```
/// struct MyView : View {
///   @MappedState var todoList: TodoList
/// }
/// ```
@available(*, deprecated)
@propertyWrapper
public struct MappedState<State>: DynamicProperty {
  @Environment(\.store) private var anyStore

  private var store: StoreProxy<State>?

  public var wrappedValue: State {
    guard let store = store else {
      fatalError("Tried mapping the state to a view, but the Store<_> doesn't conform to '\(State.self)'")
    }
    return store.state
  }

  public mutating func update() {
    self.store = anyStore.unwrap(as: State.self)
  }

  public init() {}
}
