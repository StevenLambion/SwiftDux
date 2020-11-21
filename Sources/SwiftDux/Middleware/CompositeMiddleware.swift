import Foundation

/// Use the '+' operator to combine two or more middleware together.
public struct CompositeMiddleware<State, A, B>: Middleware where A: Middleware, B: Middleware, A.State == State, B.State == State {
  @usableFromInline internal var previousMiddleware: A
  @usableFromInline internal var nextMiddleware: B

  @usableFromInline internal init(previousMiddleware: A, nextMiddleware: B) {
    self.previousMiddleware = previousMiddleware
    self.nextMiddleware = nextMiddleware
  }

  /// Unimplemented. It simply calls `store.next(_:)`.
  @inlinable public func run(store: StoreProxy<State>, action: Action) -> Action? {
    guard let action = previousMiddleware.run(store: store, action: action) else {
      return nil
    }
    return nextMiddleware.run(store: store, action: action)
  }
}

/// Compose two middleware together.
///
/// - Parameters:
///   - previousMiddleware: The  middleware to be called first.
///   - nextMiddleware: The next middleware to call.
/// - Returns: The combined middleware.
@inlinable public func + <M1, M2>(previousMiddleware: M1, _ nextMiddleware: M2) -> CompositeMiddleware<M1.State, M1, M2>
where M1: Middleware, M2: Middleware, M1.State == M2.State {
  CompositeMiddleware(previousMiddleware: previousMiddleware, nextMiddleware: nextMiddleware)
}
