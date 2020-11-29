import Combine
import Foundation

/// Subscribes to a publisher of actions, and sends them to an action dispatcher.
final internal class ActionSubscriber: Subscriber {

  typealias ReceivedCompletion = () -> Void

  private let actionDispatcher: ActionDispatcher
  private var subscription: Subscription? = nil {
    willSet {
      guard let subscription = subscription else { return }
      subscription.cancel()
    }
  }

  internal init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher
  }

  public func receive(subscription: Subscription) {
    self.subscription = subscription
    subscription.request(.max(1))
  }

  public func receive(_ input: Action) -> Subscribers.Demand {
    actionDispatcher(input)
    return .max(1)
  }

  public func receive(completion: Subscribers.Completion<Never>) {
    subscription = nil
  }

  public func cancel() {
    subscription?.cancel()
    subscription = nil
  }
}

extension Publisher where Output == Action, Failure == Never {

  /// Subscribe to a publisher of actions, and send the results to an action dispatcher.
  ///
  /// - Parameter actionDispatcher: The ActionDispatcher
  /// - Returns: A cancellable to unsubscribe.
  public func send(to actionDispatcher: ActionDispatcher) -> AnyCancellable {
    let subscriber = ActionSubscriber(actionDispatcher: actionDispatcher)

    self.subscribe(subscriber)
    return AnyCancellable { subscriber.cancel() }
  }
}
