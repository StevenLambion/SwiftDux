import Foundation
import SwiftUI

/// Retrieves the dispatcher for the given state from the environment and maps it to a property in a SwiftUI view.
/// ```
/// struct MyView : View {
///
///   @Dispatch<AppState> var dispatch: Dispatch
///
///   func login() {
///     dispatch(UserActions.login(...))
///   }
///
/// }
/// ```
@propertyDelegate
public struct MapDispatch<State> : DynamicViewProperty where State : StateType {
  @EnvironmentObject private var storeContext: StoreContext<State>
  
  private var _value: Dispatch!
  public var value: Dispatch {
    _value
  }
  
  public init() {}
  
  public mutating func update() {
    self._value = { [storeContext] in storeContext.dispatcher.send($0) }
  }
  
}
