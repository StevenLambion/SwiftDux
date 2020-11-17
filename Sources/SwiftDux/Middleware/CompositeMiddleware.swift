import Foundation

/// Use the '+' operator to combine two or more middleware together.
public struct CompositeMiddleware<State, A, B>: Middleware where A: Middleware, B: Middleware, A.State == State, B.State == State {
  private var previousMiddleware: A
  private var nextMiddleware: B

  @usableFromInline internal init(previousMiddleware: A, nextMiddleware: B) {
    self.previousMiddleware = previousMiddleware
    self.nextMiddleware = nextMiddleware
  }

  /// Unimplemented. It simply calls `store.next(_:)`.
  @inlinable public func run(store: StoreProxy<State>, action: Action) {
    store.next(action)
  }

  /// Apply the middleware to a store proxy.
  /// - Parameter store: The store proxy.
  /// - Returns: A SendAction function that performs the middleware for the provided store proxy.
  public func compile(store: StoreProxy<State>) -> SendAction {
    previousMiddleware(store: StoreProxy(proxy: store, next: nextMiddleware(store: store)))
  }
}
