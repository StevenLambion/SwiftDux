import Combine
import SwiftUI

/// Default value of the actionDispatcher environment value.
internal struct NoopActionDispatcher: ActionDispatcher {

  func send(_ action: Action) {
    print("Tried dispatching an action `\(action)` without providing a store object.")
  }

  func sendAsCancellable(_ action: Action) -> Cancellable {
    print("Tried dispatching an action `\(action)` without providing a store object.")
    return AnyCancellable {}
  }
}

internal struct ActionDispatcherKey: EnvironmentKey {
  typealias Value = ActionDispatcher
  static var defaultValue: Value = NoopActionDispatcher()
}

extension EnvironmentValues {

  /// Environment value to supply an actionDispatcher. This is used by the MappedDispatch to retrieve
  /// an action dispatcher from the environment.
  public var actionDispatcher: ActionDispatcher {
    get {
      self[ActionDispatcherKey.self]
    }
    set {
      self[ActionDispatcherKey.self] = newValue
    }
  }
}
