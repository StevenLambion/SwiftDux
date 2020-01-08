import Combine
import Foundation

/// Encapsulates multiple actions into a packaged up "action plan"
///
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
public struct ActionPlan<State>: CancellableAction where State: StateType {

  /// The body of a publishable action plan.
  ///
  /// - Parameter StoreProxy: Dispatch actions or retreive the current state from the store.
  /// - Returns: A publisher that can send actions to the store.
  public typealias Body = (StoreProxy<State>) -> AnyPublisher<Action, Never>?

  private var body: Body

  /// Create a new action plan that returns an optional publisher.
  ///
  /// - Parameter body: The body of the action plan.
  public init<P>(_ body: @escaping (StoreProxy<State>) -> P?) where P: Publisher, P.Output == Action, P.Failure == Never {
    self.body = { body($0)?.eraseToAnyPublisher() }
  }

  /// Create a new action plan.
  ///
  /// - Parameter body: The body of the action plan.
  public init(_ body: @escaping (StoreProxy<State>) -> Void) {
    self.body = {
      body($0)
      return nil
    }
  }

  /// Manually run the action plan.
  ///
  /// this can be useful to run an action plan inside a containing action plan.
  /// - Parameter store: Dispatch actions or retreive the current state from the store.
  /// - Returns: A publisher that can send actions to the store.
  public func run(_ store: StoreProxy<State>) -> AnyPublisher<Action, Never>? {
    self.body(store)
  }

  /// Send an action plan that can be cancelled.
  ///
  /// This is useful for action plans that return a publisher that require a cancellable step. For example, a web request
  /// that should be cancelled if the user navigates away from the relevant view.
  ///
  /// ```
  /// struct MyView: View {
  ///
  ///   @MappedDispatch() private var dispatch
  ///
  ///   @State private var username: String = ""
  ///   @State private var password: String = ""
  ///
  ///   @State private var signUpCancellable: AnyCancellable? = nil
  ///
  ///   var body: some View {
  ///     Group {
  ///       /// ...signup form
  ///       Button(action: self.signUp) { Text("Sign Up") }
  ///     }
  ///     .onDisappear { self.signUpCancellable?.cancel() }
  ///   }
  ///
  ///   func signUp() {
  ///     signUpCancellable = signUpActionPlan(username: username, password: password).sendAsCancellable(dispatch)
  ///   }
  ///
  /// }
  /// ```
  ///
  /// - Parameter send: The send function that dispatches an action.
  /// - Returns: AnyCancellable to cancel the action plan.
  public func sendAsCancellable(_ send: SendAction) -> Cancellable {
    var cancelled: Bool = false
    var publisherCancellable: Cancellable? = nil

    send(
      ActionPlan<State> { store -> () in
        guard cancelled == false else { return }
        guard let publisher = self.run(store) else { return }
        publisherCancellable = publisher.sink { action in
          store.send(action)
        }
      }
    )

    return AnyCancellable {
      cancelled = true
      publisherCancellable?.cancel()
    }
  }
}
