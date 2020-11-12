import Combine
import Foundation

/// Encapsulates multiple actions into a packaged up "action plan"
///
///```
///   enum UserAction {
///
///     static func loadUser(byId id: String) -> ActionPlan<AppState> {
///       ActionPlan<AppState> { store, completed in
///         guard !store.state.users.hasValue(id) else { return nil }
///         store.send(UserAction.setLoading(true))
///         return UserService.getUser(id)
///           .first()
///           .flatMap { user in
///               [
///                 UserAction.setUser(user)
///                 UserAction.setLoading(false)
///               ].publisher
///             }
///           }
///           .send(to: store, receivedCompletion: completed)
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
public struct ActionPlan<State>: RunnableAction {

  /// The body of a publishable action plan.
  ///
  /// - Parameter StoreProxy: Dispatch actions or retreive the current state from the store.
  /// - Returns: A publisher that can send actions to the store.
  public typealias Body = (StoreProxy<State>, @escaping ActionSubscriber.ReceivedCompletion) -> AnyCancellable?

  @usableFromInline
  internal var body: Body

  @usableFromInline
  internal var nextActions: [ActionPlan<State>] = []

  /// Create a new action plan that returns an optional publisher.
  ///
  /// - Parameter body: The body of the action plan.
  @inlinable public init(_ body: @escaping Body) {
    self.body = body
  }

  /// Create a new action plan that returns an optional publisher.
  ///
  /// - Parameter body: The body of the action plan.
  @inlinable public init<P>(_ body: @escaping (StoreProxy<State>) -> P) where P: Publisher, P.Output == Action, P.Failure == Never {
    self.body = { store, completed in
      body(store).send(to: store, receivedCompletion: completed)
    }
  }

  /// Create a new action plan.
  ///
  /// - Parameter body: The body of the action plan.
  @inlinable public init(_ body: @escaping (StoreProxy<State>) -> Void) {
    self.body = { store, completed in
      body(store)
      completed()
      return nil
    }
  }

  public func run<T>(store: Store<T>) -> AnyCancellable? {
    var cancellable: AnyCancellable? = nil
    let done = {
      cancellable?.cancel()
      cancellable = nil
    }
    guard let proxy = store.proxy(for: State.self, done: done) else { return nil }
    cancellable = run(proxy) { [proxy] in
      proxy.done()
    }
    return cancellable
  }

  /// Manually run the action plan.
  ///
  /// this can be useful to run an action plan inside a containing action plan.
  /// - Parameters
  ///   - store: Dispatch actions or retreive the current state from the store.
  ///   - completed: A block that's called when the plan has completed.
  /// - Returns: A publisher that can send actions to the store.
  @inlinable public func run(_ store: StoreProxy<State>, completed: @escaping ActionSubscriber.ReceivedCompletion = {}) -> AnyCancellable? {
    guard var nextAction = nextActions.first else {
      return body(store, completed)
    }

    nextAction.nextActions = Array(nextActions[1...])

    return body(store) {
      completed()
      store.send(nextAction)
    }
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
  /// }
  /// ```
  ///
  /// - Parameter dispatcher: The send function that dispatches an action.
  /// - Returns: AnyCancellable to cancel the action plan.
  @inlinable public func sendAsCancellable(_ dispatcher: ActionDispatcher) -> AnyCancellable {
    var publisherCancellable: AnyCancellable? = nil
    dispatcher(
      ActionPlan<State> { store, completed in
        publisherCancellable = self.run(store) {
          publisherCancellable = nil
          completed()
        }
        return publisherCancellable
      }
    )
    return AnyCancellable { [publisherCancellable] in publisherCancellable?.cancel() }
  }

  /// Dispatches another action plan after this one has completed. This allows
  /// action plans to be chained together to perform their actions synchronously.
  ///
  /// - Parameter actionPlans: One or mroe action plans to chain after this one.
  /// - Returns: A new action plan that chains the source plan with the provided ones in the parameters.
  @inlinable public func then(_ actionPlans: ActionPlan<State>...) -> ActionPlan<State> {
    var copy = self
    copy.nextActions.append(contentsOf: actionPlans)
    return copy
  }

  /// Calls the provided block once the action plan has completed. The current state is
  /// provided to the block.
  ///
  /// - Parameter block: A block of code to execute once the action plan has completed.
  /// - Returns: A new action plan.
  @inlinable public func then(_ block: @escaping (State) -> Void) -> ActionPlan<State> {
    then(
      ActionPlan<State> { store in
        block(store.state)
      }
    )
  }

  /// Calls the provided block once the action plan has completed.
  ///
  /// - Parameter block: A block of code to execute once the action plan has completed.
  /// - Returns: A new action plan.
  @inlinable public func then(_ block: @escaping () -> Void) -> ActionPlan<State> {
    then(
      ActionPlan<State> { _ in
        block()
      }
    )
  }
}
