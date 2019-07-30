import SwiftUI
import Combine

internal struct NoopActionDispatcher : ActionDispatcher {
  
  @discardableResult
  func send(_ action: Action) -> AnyPublisher<Void, Never> {
    print("Tried dispatching an action `\(action)` without providing a store object.")
    return Just(()).eraseToAnyPublisher()
  }
  
  func proxy(modifyAction: ActionModifier?) -> ActionDispatcher {
    print("Tried proxy an action dispatcher before providing a store object.")
    return self
  }
  
}

internal struct ActionDispatcherKey : EnvironmentKey {
  typealias Value = ActionDispatcher
  static var defaultValue: Value = NoopActionDispatcher()
}

extension EnvironmentValues {
 
  internal var actionDispatcher: ActionDispatcher {
    get {
      self[ActionDispatcherKey.self]
    }
    set {
      self[ActionDispatcherKey.self] = newValue
    }
  }
  
}
