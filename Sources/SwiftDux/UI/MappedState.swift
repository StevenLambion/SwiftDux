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
  @Environment(\.storeWrapper) private var storeWrapper

  private var storeProxy: StoreProxy<State>?

  public var wrappedValue: State {
    guard let storeProxy = storeProxy else {
      fatalError("SwiftDux Store<_> does not conform to type: \(State.self)")
    }
    return storeProxy.state
  }

  public mutating func update() {
    guard storeProxy == nil else { return }
    self.storeProxy = storeWrapper.proxy(type: State.self)
  }

  public init() {}
}
