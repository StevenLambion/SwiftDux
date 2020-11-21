import Combine
import Foundation

/// A simple middleware to perform any handling on a dispatched action.
public final class HandleActionMiddleware<State>: Middleware {
  @usableFromInline internal var perform: (StoreProxy<State>, Action) -> Action?

  /// - Parameter body: The block to call when an action is dispatched.
  @inlinable public init(perform: @escaping (StoreProxy<State>, Action) -> Action?) {
    self.perform = perform
  }

  @inlinable public func run(store: StoreProxy<State>, action: Action) -> Action? {
    perform(store, action)
  }
}
