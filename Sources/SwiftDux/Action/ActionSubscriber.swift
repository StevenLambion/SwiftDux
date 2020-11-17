import Combine
import Foundation

/// Subscribes to a publisher of actions, and sends them to an action dispatcher.
final internal class ActionSubscriber: Subscriber {

  typealias ReceivedCompletion = () -> Void

  private let actionDispatcher: ActionDispatcher
  private let receivedCompletion: ReceivedCompletion?
  private var subscription: Subscription? = nil {
    willSet {
      guard let subscription = subscription else { return }
      subscription.cancel()
    }
  }

  internal init(actionDispatcher: ActionDispatcher, receivedCompletion: ReceivedCompletion?) {
    self.actionDispatcher = actionDispatcher
    self.receivedCompletion = receivedCompletion
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
    receivedCompletion?()
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
  /// - Parameters:
  ///   - actionDispatcher: The ActionDispatcher
  ///   - receivedCompletion: An optional block called when the publisher completes.
  /// - Returns: A cancellable to unsubscribe.
  public func send(to actionDispatcher: ActionDispatcher, receivedCompletion: (() -> Void)? = nil) -> AnyCancellable {
    let subscriber = ActionSubscriber(
      actionDispatcher: actionDispatcher,
      receivedCompletion: receivedCompletion
    )
    self.subscribe(subscriber)
    return AnyCancellable { [subscriber] in
      subscriber.cancel()
    }
  }
}
