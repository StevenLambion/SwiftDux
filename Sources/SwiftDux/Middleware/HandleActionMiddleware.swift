import Combine
import Foundation

/// A simple middleware to perform any handling on a dispatched action.
public final class HandleActionMiddleware<State>: Middleware where State: StateType {

  private var perform: (StoreProxy<State>, Action) -> Void

  /// - Parameter body: The block to call when an action is dispatched.
  public init(perform: @escaping (StoreProxy<State>, Action) -> Void) {
    self.perform = perform
  }

  public func run(store: StoreProxy<State>, action: Action) {
    perform(store, action)
  }
}
