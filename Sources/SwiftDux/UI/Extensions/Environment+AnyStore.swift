import Combine
import SwiftUI

public protocol AnyStore: ActionDispatcher {
  func unwrap<T>(as type: T.Type) -> StoreProxy<T>?
}

internal final class AnyStoreWrapper<T>: AnyStore {
  let store: Store<T>

  init(store: Store<T>) {
    self.store = store
  }

  func unwrap<T>(as type: T.Type) -> StoreProxy<T>? {
    store.proxy(for: type)
  }
  
  func send(_ action: Action) {
    store.send(action)
  }
}

internal final class NoopAnyStore: AnyStore {
  func unwrap<T>(as type: T.Type) -> StoreProxy<T>? {
    return nil
  }
  
  func send(_ action: Action) {
    // Do nothing
  }
}

public final class StoreWrapperEnvironmentKey: EnvironmentKey {
  public static var defaultValue: AnyStore {
    NoopAnyStore()
  }
}

extension EnvironmentValues {
  public var store: AnyStore {
    get { self[StoreWrapperEnvironmentKey.self] }
    set { self[StoreWrapperEnvironmentKey.self] = newValue }
  }
}
