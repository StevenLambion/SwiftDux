import Combine
import SwiftUI

/// Default value of the actionDispatcher environment value.
internal struct NoopActionDispatcher: ActionDispatcher {

  func send(_ action: Action) {
    print("Tried dispatching an action `\(action)` without providing a store object.")
  }

  func proxy(modifyAction: ActionModifier? = nil) -> ActionDispatcher {
    print("Tried proxying an action dispatcher before providing a store object.")
    return self
  }
}

internal struct ActionDispatcherKey: EnvironmentKey {
  typealias Value = ActionDispatcher
  static var defaultValue: Value = NoopActionDispatcher()
}

extension EnvironmentValues {

  /// Environment value to supply an actionDispatcher. This is used by the MappedDispatch to retrieve
  /// an action dispatcher from the environment.
  internal var actionDispatcher: ActionDispatcher {
    get {
      self[ActionDispatcherKey.self]
    }
    set {
      self[ActionDispatcherKey.self] = newValue
    }
  }
}
