import Combine
import Foundation

/// Creates a proxy of the store object for use by middleware.
///
/// Middleware may use the store proxy to retreive the current state, send actions,
/// continue to the next middleware, or subscribe to store changes. With the proxy,
/// middleware don't have to worry about retaining the store. Instead, the proxy provides
/// a safe API to access a weak reference to it.
public struct StoreProxy<State> where State: StateType {

  private var getState: () -> State?

  /// Subscribe to state changes.
  public var didChange: PassthroughSubject<Action, Never>

  /// Send an action to the store.
  public var send: SendAction

  /// Send an action to the next middleware
  public var next: SendAction

  /// Retrieves the latest state from the store.
  public var state: State? {
    getState()
  }

  internal init(store: Store<State>, send: SendAction? = nil, next: SendAction? = nil) {
    let send: SendAction = send ?? { [weak store] in store?.send($0) }
    self.didChange = store.didChange
    self.getState = { [weak store] in store?.state }
    self.send = send
    self.next = next ?? send
  }
}
