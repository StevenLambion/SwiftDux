import Combine
import Foundation

/// Subscribes to a publisher of actions, and sends them to an action dispatcher.
final public class PersistSubscriber<Input, Persistor>: Subscriber where Persistor: StatePersistor, Persistor.State == Input {

  public typealias ReceivedCompletion = (Subscribers.Completion<Never>) -> Void

  let persistor: Persistor
  var subscription: Subscription? = nil {
    willSet {
      guard let subscription = subscription else { return }
      subscription.cancel()
    }
  }

  init(persistor: Persistor) {
    self.persistor = persistor
  }

  public func receive(subscription: Subscription) {
    self.subscription = subscription
    subscription.request(.max(1))
  }

  public func receive(_ input: Input) -> Subscribers.Demand {
    if persistor.save(input) {
      return .max(1)
    }
    return .none
  }

  public func receive(completion: Subscribers.Completion<Never>) {
    subscription = nil
  }
  
  public func cancel() {
    subscription?.cancel()
    subscription = nil
  }

}

extension Publisher where Output: Codable, Failure == Never {

  /// Subscribe to a publisher of actions, and send the results to an action dispatcher.
  /// - Parameter persistor: The state persistor to save the results to.
  /// - Returns: A cancellable to unsubscribe.
  public func persist<P>(with persistor: P) -> AnyCancellable where P: StatePersistor, P.State == Output {
    let subscriber = PersistSubscriber(persistor: persistor)
    self.subscribe(subscriber)
    return AnyCancellable { [subscriber] in subscriber.cancel() }
  }

}
