import SwiftUI
import Combine

internal struct StoreUpdatedKey : EnvironmentKey {
  typealias Value = PassthroughSubject<Action, Never>
  static var defaultValue: Value = PassthroughSubject<Action, Never>()
}

extension EnvironmentValues {
 
  internal var storeUpdated: PassthroughSubject<Action, Never> {
    get {
      self[StoreUpdatedKey.self]
    }
    set {
      self[StoreUpdatedKey.self] = newValue
    }
  }
  
}
