import Foundation
import Combine

public protocol Action {}

public struct NoActions: Action {}

public protocol ActionDispatcher {
  
  func send(_ action: Action)
  
}

public protocol ActionSubscriber: ActionDispatcher, Subscriber {}

extension ActionSubscriber {
  
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
