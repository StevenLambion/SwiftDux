import Foundation
import SwiftUI
import Combine

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
@propertyWrapper
public struct MappedDispatch : DynamicProperty {

  @Environment(\.actionDispatcher) private var actionDispatcher
  
  public var wrappedValue: SendAction {
    { self.actionDispatcher.send($0) }
  }

  public init() {}

}
