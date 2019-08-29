import SwiftUI
import Combine

internal struct StoreUpdatedKey : EnvironmentKey {
  typealias Value = PassthroughSubject<Action, Never>
  static var defaultValue: Value = PassthroughSubject<Action, Never>()
}

extension EnvironmentValues {
 
  /// Environment value to supply a subject that publishes store updates. This is used by the MappedState to
  /// update views when an action is dispatched.
  internal var storeUpdated: PassthroughSubject<Action, Never> {
    get {
      self[StoreUpdatedKey.self]
    }
    set {
      self[StoreUpdatedKey.self] = newValue
    }
  }
  
}
