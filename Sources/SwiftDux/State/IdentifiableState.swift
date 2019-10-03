import Foundation

/// A type of state that can be identified for tracking purposes.
///
/// This is typically used for entities stored in your state that might be accessed by id
/// or displayed in a `List` view.
public protocol IdentifiableState: StateType, Identifiable, Equatable where ID: Codable {}

extension IdentifiableState {

  /// The hash value of the state based on the id.
  ///
  /// - Parameter hasher: The hasher to apply the hash into.
  public var hashValue: Int {
    return id.hashValue
  }

  /// Applies the hash of the id to the hasher.
  ///
  /// - Parameter hasher: The hasher to apply the id's hash into.
  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }

}
