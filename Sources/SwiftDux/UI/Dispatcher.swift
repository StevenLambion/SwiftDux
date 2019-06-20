import Foundation
import SwiftUI

/// Retrieves the dispatcher for the given state from the environment and maps it to a property in a SwiftUI view.
/// ```
/// struct MyView : View {
///
///   @Dispatcher var dispatch: Dispatch
///
///   func login() {
///     dispatch(UserActions.login(...))
///   }
///
/// }
/// ```
@propertyDelegate
public struct Dispatcher : DynamicViewProperty {
  @EnvironmentObject private var dispatcherContext: DispatcherContext

  private var _value: Dispatch!
  public var value: Dispatch {
    _value
  }

  public init() {}

  public mutating func update() {
    self._value = { [dispatcherContext] in dispatcherContext.dispatcher.send($0) }
  }

}
