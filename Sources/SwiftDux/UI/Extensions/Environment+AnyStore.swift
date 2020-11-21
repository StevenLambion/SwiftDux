import Combine
import SwiftUI

/// A type-erased wrapper of a Store.
public protocol AnyStore: ActionDispatcher {

  /// Unwrap the store for a specific state type.
  /// - Parameter type: The type of state expected.
  /// - Returns: The unwrapped store if successful.
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

  func sendAsCancellable(_ action: Action) -> Cancellable {
    store.sendAsCancellable(action)
  }
}

struct NoopAnyStore: AnyStore {
  func unwrap<T>(as type: T.Type) -> StoreProxy<T>? {
    return nil
  }

  func send(_ action: Action) {
    // Do nothing
  }

  func sendAsCancellable(_ action: Action) -> Cancellable {
    AnyCancellable {}
  }
}

public final class StoreWrapperEnvironmentKey: EnvironmentKey {
  public static var defaultValue: AnyStore {
    NoopAnyStore()
  }
}

extension EnvironmentValues {

  /// A type-erased wrapper of the Store.
  public var store: AnyStore {
    get { self[StoreWrapperEnvironmentKey.self] }
    set { self[StoreWrapperEnvironmentKey.self] = newValue }
  }
}
