import Combine
import Foundation

/// Publishes state changes from the store.
public final class StorePublisher: Publisher {
  public typealias Failure = Never
  public typealias Output = Void
  private let subject = PassthroughSubject<Void, Never>()
  private let publisher: AnyPublisher<Void, Never>

  /// Initiate a StorePublisher.
  ///
  /// - Parameters:
  ///   - dueTime: The throttle time before publishing an update.
  ///   - scheduler: The scheduler for the published update.
  public init<S>(throttleFor dueTime: S.SchedulerTimeType.Stride, scheduler: S) where S: Scheduler {
    self.publisher =
      subject
      .throttle(for: dueTime, scheduler: scheduler, latest: false)
      .share()
      .eraseToAnyPublisher()
  }

  public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Void {
    publisher.receive(subscriber: subscriber)
  }

  internal func send() {
    subject.send()
  }
}
