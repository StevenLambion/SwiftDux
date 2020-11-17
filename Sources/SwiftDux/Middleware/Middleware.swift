import Combine
import Foundation

/// Middleware perform actions on the the store when actions are dispatched to it.
///
/// Before an action is given to a reducer, middleware have an opportunity to handle it
/// themselves. They may dispatch their own actions, transform the current action, or
/// block an incoming ones from continuing.
///
/// Middleware can also be used to set up external hooks from services.
///
/// For a reducer's own state and actions, implement the `reduce(state:action:)`.
/// For subreducers, implement the `reduceNext(state:action:)` method.
public protocol Middleware {
  associatedtype State

  /// Perform any middleware actions within this function.
  ///
  /// - Parameters:
  ///   - store: The store object. Use `store.next` when the middleware is complete.
  ///   - action: The latest dispatched action to process.
  func run(store: StoreProxy<State>, action: Action)

  /// Compiles the middleware into a SendAction closure.
  /// - Parameter store: A reference to the store used by the middleware.
  /// - Returns: The SendAction that performs the middleware.
  func compile(store: StoreProxy<State>) -> SendAction
}

extension Middleware {

  /// Apply the middleware to a store proxy.
  /// - Parameter store: The store proxy.
  /// - Returns: A SendAction function that performs the middleware for the provided store proxy.
  @inlinable public func callAsFunction(store: StoreProxy<State>) -> SendAction {
    self.compile(store: store)
  }

  @inlinable public func compile(store: StoreProxy<State>) -> SendAction {
    { action in self.run(store: store, action: action) }
  }
}

/// Compose two middleware together.
/// - Parameters:
///   - previousMiddleware: The  middleware to be called first.
///   - nextMiddleware: The next middleware to call.
/// - Returns: The combined middleware.
@inlinable public func + <M1, M2>(previousMiddleware: M1, _ nextMiddleware: M2) -> CompositeMiddleware<M1.State, M1, M2>
where M1: Middleware, M2: Middleware, M1.State == M2.State {
  CompositeMiddleware(previousMiddleware: previousMiddleware, nextMiddleware: nextMiddleware)
}

internal final class NoopMiddleware<State>: Middleware {

  @inlinable func run(store: StoreProxy<State>, action: Action) {
    store.next(action)
  }
}
