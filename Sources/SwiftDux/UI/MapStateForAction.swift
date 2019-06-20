import Foundation
import SwiftUI

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
