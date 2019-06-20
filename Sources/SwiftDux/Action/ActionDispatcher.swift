import Foundation
import Combine

/// An object that dispatches actions to a store.
///
/// Once an action is sent, the sender shouldn't expect anything to occur. Instead, it should rely
/// solely on changes to the state of the application to respond.
public protocol ActionDispatcher {

  /// Sends an action to a reducer to mutate the state of the application.
  /// - Parameter action: An action to dispatch to the store.
  @discardableResult
  func send(_ action: Action) -> AnyPublisher<Void, Never>

}

// Default `Subscriber` implementation
extension ActionDispatcher where Self : Subscriber, Self.Input == Action?, Self.Failure == Never {

  public func receive(_ input: Action?) -> Subscribers.Demand {
    if  let input = input {
      self.send(input)
    }
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
