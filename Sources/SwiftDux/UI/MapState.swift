import Foundation
import SwiftUI

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
