import Foundation

/// A type of state that can be identified for tracking purposes.
///
/// This is typically used for entities stored in your state that might be accessed by id
/// or displayed in a `List` view.
public protocol IdentifiableState: StateType, Identifiable where ID: Codable {}

extension IdentifiableState {

  /// The hash value of the state based on the id.
  ///
  /// - Parameter hasher: The hasher to apply the hash into.
  @inlinable public var hashValue: Int {
    id.hashValue
  }

  /// Applies the hash of the id to the hasher.
  ///
  /// - Parameter hasher: The hasher to apply the id's hash into.
  @inlinable public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }
}
