import Combine
import SwiftUI

internal struct StoreUpdatedKey: EnvironmentKey {
  typealias Value = AnyPublisher<Action, Never>
  static var defaultValue: Value = PassthroughSubject<Action, Never>().eraseToAnyPublisher()
}

extension EnvironmentValues {

  /// Environment value to supply a subject that publishes store updates. This is used by the MappedState to
  /// update views when an action is dispatched.
  internal var storeUpdated: AnyPublisher<Action, Never> {
    get {
      self[StoreUpdatedKey.self]
    }
    set {
      self[StoreUpdatedKey.self] = newValue
    }
  }
}
