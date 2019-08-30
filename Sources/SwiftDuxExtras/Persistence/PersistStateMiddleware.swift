import Foundation
import Combine
import SwiftDux
import UIKit

/// Hooks up state peristence to the store.
/// - Parameters
///   - persistor: The state persistor to use.
///   - saveOnChange: Saves the state when it changes, else, it saves when the app enters the backgroound.
///   - debounceFor: The debounce interval for saving on changes.
public func PersistStateMiddleware<State, SP> (
  _ persistor: SP,
  saveOnChange: Bool = true,
  debounceFor interval: RunLoop.SchedulerTimeType.Stride = .milliseconds(100)
) -> Middleware<State> where SP : StatePersistor, State == SP.State, SP.Failure == Never, SP.Input == State {
  { store in { action in
    defer { store.next(action) }
    guard case .prepare = action as? StoreAction else { return }
    if saveOnChange {
      persistor.save(from: store, debounceFor: interval)
    } else {
      let publisher = NotificationCenter.default
        .publisher(for: UIApplication.didEnterBackgroundNotification)
        .compactMap { _ in store.state }
      persistor.save(from: publisher)
    }
    if let state = persistor.restore() {
      store.send(PersistStateAction<State>.restore(state: state))
    }
  }}
}

