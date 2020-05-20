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
public struct MappedState<State>: DynamicProperty {
  @Environment(\.store) private var anyStore

  private var store: StoreProxy<State>?

  public var wrappedValue: State {
    guard let store = store else {
      fatalError("SwiftDux Store<_> does not conform to type: \(State.self)")
    }
    return store.state
  }

  public mutating func update() {
    guard store == nil else { return }
    self.store = anyStore.unwrap(as: State.self)
  }

  public init() {}
}
