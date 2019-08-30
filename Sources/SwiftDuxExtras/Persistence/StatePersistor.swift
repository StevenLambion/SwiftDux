import Foundation
import Combine
import SwiftDux

/// Persists and restores application state.
public protocol StatePersistor : Subscriber {
  
  /// The type of application state to persist.
  associatedtype State : Codable
  
  /// The location where the state will be stored.
  var location: StatePersistentLocation { get }
  
  /// Initiate a new persistor for the give location.
  init(location: StatePersistentLocation)
  
  /// Encodes the state into a raw data object.
  func encode(state: State) throws -> Data
  
  /// Decode raw data into a new state object.
  /// - Parameter data: The data to decode.
  func decode(data: Data) throws -> State

}

extension StatePersistor {
  
  /// Initiate a new json persistor with a given location of the stored data.
  /// - Parameter location: The location of the stored data.
  public init(fileUrl: URL? = nil) {
    self.init(location: LocalStatePersistentLocation(fileUrl: fileUrl))
  }
  
  /// Save the state object to a storage location.
  /// It returns true if it succeeds.
  @discardableResult
  public func save(_ state: State) -> Bool {
    do {
      let data = try encode(state: state)
      return location.save(data)
    } catch {
      return false
    }
  }
  
  /// Restore the state from storage.
  public func restore() -> State? {
    guard let data = location.restore() else { return nil }
    do {
      return try decode(data: data)
    } catch {
      return nil
    }
  }
  
}

extension StatePersistor where Self : Subscriber, Self.Input == State, Self.Failure == Never {
  
  /// Subscribe to a publisher to save the state automatically.
  /// - Parameters
  ///   - from: The publisher to subsctibe to.
  ///   - debounceFor: The time interval to debounce the updates against.
  public func save<P>(
     from publisher: P,
     debounceFor interval: RunLoop.SchedulerTimeType.Stride = .milliseconds(100)
   ) where P : Publisher, P.Output == Input, P.Failure == Never {
    publisher
      .debounce(for: interval, scheduler: RunLoop.main)
      .subscribe(self)
   }
  
  /// Subscribe to a store to save the state automatically.
  /// - Parameters
  ///   - from: The store to subsctibe to.
  ///   - debounceFor: The time interval to debounce the updates against.
  public func save(
    from store: Store<State>,
    debounceFor interval: RunLoop.SchedulerTimeType.Stride = .milliseconds(100)
  ) {
    save(
      from: store.didChange.compactMap { [weak store] _ in store?.state },
      debounceFor: interval
    )
  }
  
  /// Subscribe to a store to save the state automatically.
  /// - Parameters
  ///   - from: The store to subsctibe to.
  ///   - debounceFor: The time interval to debounce the updates against.
  public func save(
    from store: StoreProxy<State>,
    debounceFor interval: RunLoop.SchedulerTimeType.Stride = .milliseconds(100)
  ) {
    save(
      from: store.didChange.compactMap { _ in store.state },
      debounceFor: interval
    )
  }
  
  public func receive(subscription: Subscription) {
    subscription.request(.max(1))
  }
  
  public func receive(_ input: State) -> Subscribers.Demand {
    if save(input) {
      return .max(1)
    }
    return .none
  }
  
  public func receive(completion: Subscribers.Completion<Never>) {
    switch completion {
    case .failure(let error):
      print("Failed to encode the state object.")
      print(error)
    case .finished:
      break
    }
  }
  
}
