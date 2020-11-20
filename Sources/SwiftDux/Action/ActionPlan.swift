import Combine
import Foundation

/// Encapsulates external business logic outside of a reducer into a special kind of action.
///
///```
///   enum UserAction {
///
///     static func loadUser(byId id: String) -> ActionPlan<AppState> {
///       ActionPlan<AppState> { store in
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
///       }
///     }
///   }
///
///   // Inside a view:
///
///   func body(props: Props) -> some View {
///     UserInfo(user: props.user)
///       .onAppear { dispatch(UserAction.loadUser(byId: self.id)) }
///   }
///```.
public struct ActionPlan<State>: RunnableAction {

  @usableFromInline internal typealias Body = (StoreProxy<State>) -> AnyPublisher<Action, Never>

  @usableFromInline
  internal var body: Body

  /// Initiate an action plan that returns a publisher of actions.
  ///
  /// - Parameter body: The body of the action plan.
  @inlinable public init<P>(_ body: @escaping (StoreProxy<State>)->P) where P: Publisher, P.Output == Action, P.Failure == Never {
    self.body = { store in body(store).eraseToAnyPublisher() }
  }
  
  /// Initiate an asynchronous action plan that completes after the first emitted void value from its publisher.
  ///
  /// Use this method to wrap asynchronous code in a publisher like `Future<Void, Never>`.
  /// - Parameter body: The body of the action plan.
  @inlinable public init<P>(_ body: @escaping (StoreProxy<State>)->P) where P: Publisher, P.Output == Void, P.Failure == Never {
    self.body = { store in
        body(store)
          .first()
          .compactMap { _ -> Action? in nil }
          .eraseToAnyPublisher()
    }
  }

  /// Initiate a synchronous action plan.
  ///
  /// The plan expects to complete once the body has returned.
  /// - Parameter body: The body of the action plan.
  @inlinable public init(_ body: @escaping (StoreProxy<State>) -> Void) {
    self.body = { store in
      body(store)
      return Empty().eraseToAnyPublisher()
    }
  }

  @inlinable public func run<T>(store: StoreProxy<T>) -> AnyPublisher<Action, Never> {
    guard let storeProxy = store.proxy(for: State.self) else {
      fatalError("Store does not support type `\(State.self)` from ActionPlan.")
    }
    return body(storeProxy)
  }
}
