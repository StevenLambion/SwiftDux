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
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
public struct MappedDispatch : DynamicProperty {

  @EnvironmentObject private var dispatchConnection: DispatchConnection
  
  public var wrappedValue: SendAction {
    { [weak dispatchConnection] in dispatchConnection?.send(action: $0) }
  }

  public init() {}

}
