import Foundation
import Combine

/// Specifies a type as a dispatchable action.
///
/// Typically this is done with enum types, however,  it could be added to protocols or structs if
/// a more complex solution is needed.
///
/// Enum Example:
///   enum TodoList: Action {
///     case setItems(items: [TodoItem])
///     case addItem(withText: String)
///     case removeItems(at: IndexSet)
///     case moveItems(at: IndexSet, to: Int)
///   }
public protocol Action {}

/// A noop action used by reducers that may not have their own actions.
public struct EmptyAction: Action {}

/// An object that dispatches actions to a store.
///
/// Once an action is sent, the sender shouldn't expect anything to occur. Instead, it should rely
/// solely on changes to the state of the application to respond.
public protocol ActionDispatcher: Subscriber where Input == Action, Failure == Never {
  
  /// Sends an action to a reducer to mutate the state of the application.
  /// - Parameter action: An action to dispatch to the store.
  func send(_ action: Action)
  
  /// Subscribes the dispatcher to an action publisher
  /// - Parameter actionPublisher: A publisher that emits actions to be dispatched.
  /// - Returns: A publisher that events when an action is sent. It can also be used to notify when the publisher is completed.
  @discardableResult
  func send<P>(_ actionPublisher: P) -> AnyPublisher<Void, Never> where P : Publisher, P.Output == Action, P.Failure == Never
  
}

// Default `Subscriber` implementation
extension ActionDispatcher {
  
  @discardableResult
  public func send<P>(_ actionPublisher: P) -> AnyPublisher<Void, Never> where P : Publisher, P.Output == Action, P.Failure == Never {
    actionPublisher.subscribe(self)
    return actionPublisher.map { _ in () }.eraseToAnyPublisher()
  }
  
  public func receive(_ input: Action) -> Subscribers.Demand {
    self.send(input)
    return .unlimited
  }
  
  public func receive(completion: Subscribers.Completion<Never>) {
    switch completion {
    case .finished:
      break
    case .failure:
      fatalError("This should never be called.")
    }
  }
  
  public func receive(subscription: Subscription) {
    subscription.request(.unlimited)
  }
  
}
