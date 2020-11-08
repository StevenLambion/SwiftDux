import Combine
import Foundation

/// Publishes state changes from the store.
public final class StorePublisher: Publisher {
  public typealias Failure = Never
  public typealias Output = Void
  private let subject = PassthroughSubject<Void, Never>()

  public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Void {
    subject.receive(subscriber: subscriber)
  }

  internal func send() {
    subject.send()
  }
}
