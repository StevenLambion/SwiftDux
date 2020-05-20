import Combine
import SwiftUI

internal protocol AnyStoreWrapper {
  func proxy<T>(type: T.Type) -> StoreProxy<T>?
}

internal final class StoreWrapper<T>: AnyStoreWrapper {
  let store: Store<T>

  init(store: Store<T>) {
    self.store = store
  }

  func proxy<T>(type: T.Type) -> StoreProxy<T>? {
    store.proxy(for: type)
  }
}

internal final class NoopStoreWrapper: AnyStoreWrapper {
  func proxy<T>(type: T.Type) -> StoreProxy<T>? {
    return nil
  }
}

internal final class StoreWrapperEnvironmentKey: EnvironmentKey {
  static var defaultValue: AnyStoreWrapper = NoopStoreWrapper()
}

extension EnvironmentValues {
  var storeWrapper: AnyStoreWrapper {
    get { self[StoreWrapperEnvironmentKey.self] }
    set { self[StoreWrapperEnvironmentKey.self] = newValue }
  }
}
