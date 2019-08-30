import Foundation

/// The stored location of the application state.
///
/// This is used by the state persistor to store or retreieve the state from
/// a storage location.
public protocol StatePersistentLocation {
  
  /// Save the state data to storage.
  /// - Parameter data: The data to save.
  func save(_ data: Data) -> Bool
  
  /// Retreive the state from storage.
  func restore() -> Data?
  
}
