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

  /// Perform any middleware actions within this function.
  ///
  /// - Parameters:
  ///   - store: The store object. Use `store.next` when the middleware is complete.
  ///   - action: The latest dispatched action to process.
  func run<State>(store: StoreProxy<State>, action: Action) where State: StateType

}

extension Middleware {

  internal func compile<State>(store: (StoreProxy<State>)) -> SendAction {
    { action in self.run(store: store, action: action) }
  }

}
