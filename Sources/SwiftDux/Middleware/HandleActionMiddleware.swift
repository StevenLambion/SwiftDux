import Combine
import Foundation

/// A simple middleware to perform any handling on a dispatched action.
public final class HandleActionMiddleware<State>: TypedMiddleware<State> where State: StateType {

  private var body: (StoreProxy<State>, Action) -> Void

  /// - Parameter body: The block to call when an action is dispatched.
  public init(body: @escaping (StoreProxy<State>, Action) -> Void) {
    self.body = body
  }

  public override func run(store: StoreProxy<State>, action: Action) {
    body(store, action)
  }
}
