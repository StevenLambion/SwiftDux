import Combine
import Foundation
import SwiftDux

/// Persist the application state as JSON.
public final class JSONStatePersistor<State>: StatePersistor where State: Codable {

  /// The storage location of the JSON data.
  public let location: StatePersistentLocation

  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  private var subscription: Subscription? {
    willSet {
      guard let subscription = subscription else { return }
      subscription.cancel()
    }
  }

  /// Initiate a new state persistor with a given location of the stored data.
  ///
  /// - Parameter location: The location of the stored data.
  public init(location: StatePersistentLocation) {
    self.location = location
  }

  /// Encode the state to JSON data.
  ///
  /// - Parameter state: The state
  /// - Returns: The encoded state
  public func encode(state: State) throws -> Data {
    try encoder.encode(state)
  }

  /// Decode the JSON data into a new state.
  ///
  /// - Parameter data: The json data
  /// - Returns: The decoded state
  public func decode(data: Data) throws -> State {
    try decoder.decode(State.self, from: data)
  }
}
