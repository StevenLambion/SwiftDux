import Foundation
import SwiftUI

/// Retrieves the current application state from thje environment and maps it to a property in a SwiftUI view.
/// ```
/// struct MyView : View {
///
///   @MapState var state: AppState
///
/// }
/// ```
@propertyDelegate
public struct MapState<State: StateType> : DynamicViewProperty {
  
  @EnvironmentObject private var storeContext: StoreContext<State>
  
  private var _value: State!
  
  public var value: State {
    return _value
  }
  
  public init() {}
  
  public mutating func update() {
    self._value = storeContext.store.state
  }
  
}
