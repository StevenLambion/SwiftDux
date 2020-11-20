import Combine
import Foundation

/// Extends the store functionality by providing a middle layer between dispatched actions and the store's reducer.
///
/// Before an action is given to a reducer, middleware have an opportunity to handle it
/// themselves. They may dispatch their own actions, transform the current action, or
/// block it entirely.
///
/// Middleware can also be used to set up external hooks from services.
public protocol Middleware {
  associatedtype State

  /// Perform any middleware actions within this function.
  ///
  /// - Parameters:
  ///   - store: The store object. Use `store.next` when the middleware is complete.
  ///   - action: The latest dispatched action to process.
  func run(store: StoreProxy<State>, action: Action) -> Action?

  /// Compiles the middleware into a SendAction closure.
  ///
  /// - Parameter store: A reference to the store used by the middleware.
  /// - Returns: The SendAction that performs the middleware.
  func compile(store: StoreProxy<State>) -> SendAction
}

extension Middleware {

  /// Apply the middleware to a store proxy.
  ///
  /// - Parameter store: The store proxy.
  /// - Returns: A SendAction function that performs the middleware for the provided store proxy.
  @inlinable public func callAsFunction(store: StoreProxy<State>) -> SendAction {
    self.compile(store: store)
  }

  @inlinable public func compile(store: StoreProxy<State>) -> SendAction {
    { action in _ = self.run(store: store, action: action) }
  }
}

internal final class NoopMiddleware<State>: Middleware {

  @inlinable func run(store: StoreProxy<State>, action: Action) -> Action? {
    action
  }
}
