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

  /// Create an action plan that returns a publisher.
  ///
  /// - Parameter body: The body of the action plan.
  @inlinable public init<P>(_ body: @escaping (StoreProxy<State>) -> P) where P: Publisher, P.Output == Action, P.Failure == Never {
    self.body = { store in body(store).eraseToAnyPublisher() }
  }

  /// Create a synchronous action plan. The plan expects to be completed once the body has returned.
  ///
  /// - Parameter body: The body of the action plan.
  @inlinable public init(_ body: @escaping (StoreProxy<State>) -> Void) {
    self.body = { store in
      body(store)
      return Empty().eraseToAnyPublisher()
    }
  }

  /// Create an asynchronous action plan that returns a cancellable.
  ///
  /// - Parameter body: The body of the action plan.
  @inlinable public init(_ body: @escaping (StoreProxy<State>, @escaping () -> Void) -> Cancellable) {
    self.body = { store in
      var cancellable: Cancellable? = nil
      return Deferred {
        Future<Void, Never> { promise in
          cancellable = body(store) {
            promise(.success(()))
          }
        }
        .compactMap { _ -> Action? in nil }
      }
      .handleEvents(receiveCancel: { cancellable?.cancel() })
      .eraseToAnyPublisher()
    }
  }

  @inlinable public func run<T>(store: Store<T>) -> AnyPublisher<Action, Never> {
    guard let storeProxy = store.proxy(for: State.self) else {
      fatalError("Store does not support type `\(State.self)` from ActionPlan.")
    }
    return body(storeProxy)
  }
}
