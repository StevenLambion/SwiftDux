import Combine
import Foundation
import SwiftUI

/// Injects an ActionDispatcher as a property in a view to dispatch actions.
/// ```
/// struct MyView : View {
///   @Dispatch var dispatch
///
///   func handleClick() {
///     dispatch(AppAction.doSomething())
///   }
/// }
/// ```
@propertyWrapper
public struct Dispatch: DynamicProperty {
  @Environment(\.actionDispatcher) private var actionDispatcher: ActionDispatcher

  public var wrappedValue: ActionDispatcher {
    actionDispatcher
  }

  public init() {}
}

@available(*, deprecated, renamed: "Dispatch")
public typealias MappedDispatch = Dispatch
