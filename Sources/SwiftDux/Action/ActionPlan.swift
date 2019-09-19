import Foundation
import Combine

/// Encapsulates multiple actions into a packaged up "action plan"
///```
///   enum UserAction {
///
///     static func loadUser(byId id: String) -> ActionPlan<AppState> {
///       ActionPlan<AppState> { store in
///         guard !store.state?.users.hasValue(id) else { return nil }
///         store.send(UserAction.setLoading(true))
///         return UserService.getUser(id)
///           .first()
///           .flatMap { user in
///               Publishers.Sequence<[Action], Never>(sequence: [
///                 UserAction.setUser(user)
///                 UserAction.setLoading(false)
///               ])
///             }
///           }
///       }
///     }
///
///   }
///
///   // Somewhere inside a view:
///
///   func loadUser() {
///     dispatch(UserAction.loadUser(byId: self.id))
///   }
///```.
public struct ActionPlan<State>: Action where State: StateType {

  /// The body of a publishable action plan.
  /// - Parameters:
  ///   - dispatch: Dispatches an action synchronously.
  ///   - getState: Gets the latest snapshot of the application's state.
  /// - Returns: A publisher that can send actions to the store.
  public typealias Body = (StoreProxy<State>) -> AnyPublisher<Action, Never>?

  private var body: Body

  /// Create a new action plan that returns an optional publisher.
  /// - Parameter body: The body of the action plan.
  public init<P>(_ body: @escaping (StoreProxy<State>) -> P?) where P: Publisher, P.Output == Action, P.Failure == Never {
    self.body = { body($0)?.eraseToAnyPublisher() }
  }

  /// Create a new action plan.
  /// - Parameter body: The body of the action plan.
  public init(_ body: @escaping (StoreProxy<State>) -> ()) {
    self.body = { body($0); return nil;  }
  }

  /// Manually run the action plan. This can be useful to run an action plan inside containing action plan.
  public func run(_ store: StoreProxy<State>) -> AnyPublisher<Action, Never>? {
    self.body(store)
  }
}
