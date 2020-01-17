import Combine
import Foundation

/// Subscribes to a publisher of actions, and sends them to an action dispatcher.
final public class ActionSubscriber: Subscriber {

  public typealias ReceivedCompletion = () -> Void

  let sendAction: SendAction
  let receivedCompletion: ReceivedCompletion?

  var subscription: Subscription? = nil {
    willSet {
      guard let subscription = subscription else { return }
      subscription.cancel()
    }
  }

  init(sendAction: @escaping SendAction, receivedCompletion: ReceivedCompletion?) {
    self.sendAction = sendAction
    self.receivedCompletion = receivedCompletion
  }

  public func receive(subscription: Subscription) {
    self.subscription = subscription
    subscription.request(.max(1))
  }

  public func receive(_ input: Action) -> Subscribers.Demand {
    sendAction(input)
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
  /// - Parameters:
  ///   - actionDispatcher: The ActionDispatcher
  ///   - receivedCompletion: An optional block called when the publisher completes.
  /// - Returns: A cancellable to unsubscribe.
  public func send(to actionDispatcher: ActionDispatcher, receivedCompletion: ActionSubscriber.ReceivedCompletion? = nil) -> AnyCancellable {
    self.send(to: actionDispatcher.send, receivedCompletion: receivedCompletion)
  }

  /// Subscribe to a publisher of actions, and send the results to an action dispatcher.
  /// - Parameters:
  ///   - sendAction: A block that dispatches actions..
  ///   - receivedCompletion: An optional block called when the publisher completes.
  /// - Returns: A cancellable to unsubscribe.
  public func send(to sendAction: @escaping SendAction, receivedCompletion: ActionSubscriber.ReceivedCompletion? = nil) -> AnyCancellable {
    let subscriber = ActionSubscriber(
      sendAction: sendAction,
      receivedCompletion: receivedCompletion
    )
    self.subscribe(subscriber)
    return AnyCancellable { [subscriber] in
      subscriber.cancel()
    }
  }

}
