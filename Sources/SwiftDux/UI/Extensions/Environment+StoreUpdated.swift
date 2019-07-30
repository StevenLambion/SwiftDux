import SwiftUI
import Combine

internal struct StoreUpdatedKey : EnvironmentKey {
  typealias Value = AnyPublisher<Action, Never>
  static var defaultValue: Value = Future<Action, Never> { _ in }.eraseToAnyPublisher()
}

extension EnvironmentValues {
 
  internal var storeUpdated: AnyPublisher<Action, Never> {
    get {
      self[StoreUpdatedKey.self]
    }
    set {
      self[StoreUpdatedKey.self] = newValue
    }
  }
  
}
