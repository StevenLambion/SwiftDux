import Combine
import Foundation
import SwiftUI

/// Injects a function as a property in a view to dispatch actions to the provided store.
/// ```
/// struct MyView : View {
///
///   @MappedDispatch() var dispatch
///
///   func handleClick() {
///     dispatch(AppAction.doSomething())
///   }
///
/// }
/// ```
@available(*, deprecated, message: "Use @Environment(.\\actionDispatcher) instead")
@propertyWrapper
public struct MappedDispatch: DynamicProperty {
  @Environment(\.actionDispatcher) private var actionDispatcher: ActionDispatcher

  public var wrappedValue: ActionDispatcher {
    actionDispatcher
  }

  public init() {}
}
