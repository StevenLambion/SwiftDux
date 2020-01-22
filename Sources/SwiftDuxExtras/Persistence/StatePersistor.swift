import Combine
import Foundation
import SwiftDux

/// Persists and restores application state.
public protocol StatePersistor {

  /// The type of application state to persist.
  associatedtype State: StateType

  /// The location where the state will be stored.
  var location: StatePersistentLocation { get }

  /// Initiate a new persistor for the give location.
  ///
  /// - Parameter location: The location where the data will be saved and restored from.
  init(location: StatePersistentLocation)

  /// Encodes the state into a raw data object.
  ///
  ///  - Parameter state: The state to encode
  /// - Returns: The encoded state.
  func encode(state: State) throws -> Data

  /// Decode raw data into a new state object.
  ///
  /// - Parameter data: The data to decode.
  /// - Returns: The decoded state
  func decode(data: Data) throws -> State

}

extension StatePersistor {

  /// Initiate a new json persistor with a given location of the stored data on the local file system.
  ///
  /// - Parameter fileUrl: The url where the state will be saved and restored from on the local file system.
  public init(fileUrl: URL? = nil) {
    self.init(location: LocalStatePersistentLocation(fileUrl: fileUrl))
  }

  /// Save the state object to a storage location.
  ///
  /// - Parameter state: The state to save.
  /// - Returns: True if successful.
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
  ///
  /// - Returns: The state if successful.
  public func restore() -> State? {
    guard let data = location.restore() else { return nil }
    do {
      return try decode(data: data)
    } catch {
      return nil
    }
  }

  /// Subscribe to a store to save the state automatically.
  ///
  /// - Parameters
  ///   - store: The store to subsctibe to.
  ///   - interval: The time interval to debounce the updates against.
  /// - Returns: A cancellable to unsubscribe from the store.
  public func save(
    from store: Store<State>,
    debounceFor interval: RunLoop.SchedulerTimeType.Stride = .seconds(1)
  ) -> AnyCancellable {
    store.didChange
      .filter { !($0 is StoreAction<State>) }
      .debounce(for: interval, scheduler: RunLoop.main)
      .compactMap { [weak store] (action: Action) in store?.state }
      .persist(with: self)
  }

  /// Subscribe to a store to save the state automatically.
  ///
  /// - Parameters
  ///   - store: The store to subsctibe to.
  ///   - interval: The time interval to debounce the updates against.
  /// - Returns: A cancellable to unsubscribe from the store.
  public func save(
    from store: StoreProxy<State>,
    debounceFor interval: RunLoop.SchedulerTimeType.Stride = .seconds(1)
  ) -> AnyCancellable {
    store.didChange
      .filter { !($0 is StoreAction<State>) }
      .debounce(for: interval, scheduler: RunLoop.main)
      .compactMap { _ in store.state }
      .persist(with: self)
  }
}
