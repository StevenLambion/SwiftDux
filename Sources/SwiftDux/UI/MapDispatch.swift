import Foundation
import SwiftUI

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
