import Foundation
import SwiftUI

/// Retrieves the current application state from thje environment and maps it to a property in a SwiftUI view when a give action type is dispatched.
/// ```
/// struct MyView : View {
///
///   @MapStateForAction<AppState, UserAction> var state: AppState
///
/// }
/// ```
@propertyDelegate
public struct MapStateForAction<State: StateType, KindOfAction> : DynamicViewProperty where KindOfAction : Action {
  
  @EnvironmentObject private var storeContext: StoreContext<State>
  
  private var _value: State?
  
  public var value: State {
    return _value!
  }
  
  public init() {}
  
  public mutating func update() {
    if self._value == nil || storeContext.lastAction is KindOfAction {
      self._value = storeContext.store.state
    }
  }
  
}
