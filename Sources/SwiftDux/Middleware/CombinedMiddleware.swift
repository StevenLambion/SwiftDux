import Foundation

/// Combines two middleware together.
public struct CombinedMiddleware<State, A, B>: Middleware where A: Middleware, B: Middleware, A.State == State, B.State == State {
  var previousMiddleware: A
  var nextMiddleware: B

  /// Unimplemented. It simply calls `store.next(_:)`.
  public func run(store: StoreProxy<State>, action: Action) {
    store.next(action)
  }

  /// Apply the middleware to a store proxy.
  /// - Parameter store: The store proxy.
  /// - Returns: A SendAction function that performs the middleware for the provided store proxy.
  func callAsFunction(store: StoreProxy<State>) -> SendAction {
    previousMiddleware(store: StoreProxy(store: store, next: nextMiddleware(store: StoreProxy(store: store))))
  }
}
