import Foundation
import Combine
import SwiftDux

/// Hooks up state peristence to the store.
/// - Parameter persistor: The state persistor to use.
public func PersistStateMiddleware<State, SP> (
  _ persistor: SP
) -> Middleware<State> where SP : StatePersistor, State == SP.State, SP.Failure == Never, SP.Input == State {
  { store in { action in
    switch action as? StoreAction {
    case .prepare:
      persistor.save(from: store)
      if let state = persistor.restore() {
        store.send(PersistStateAction<State>.restore(state: state))
      }
    default:
      break
    }
    store.next(action)
  }}
}

