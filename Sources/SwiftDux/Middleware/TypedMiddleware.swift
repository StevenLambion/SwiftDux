import Combine
import Foundation

/// An abstract class for middleware that required a known state type when initialized.
///
/// By default, this middleware does nothing. The `run(store:action:)` method should be
/// overridden to implement the middleware functionality.
open class TypedMiddleware<State>: Middleware where State: StateType {

  public init() {}

  public func run<StoreState>(store: StoreProxy<StoreState>, action: Action) where StoreState: StateType {
    guard let typedStore = store as? StoreProxy<State> else {
      print("The state type doesn't match the expected type of the TypedMiddleware. Passing the action off.")
      return store.next(action)
    }
    run(store: typedStore, action: action)
  }

  /// Subclasses should override this method to implement their functionality.
  ///
  /// - Parameters
  ///  - store: The store object.
  ///  - action: The dispatched action.
  open func run(store: StoreProxy<State>, action: Action) {
    print("The TypedMiddleware's run function is unimplemented. Passing the action off.")
    store.next(action)
  }
}
