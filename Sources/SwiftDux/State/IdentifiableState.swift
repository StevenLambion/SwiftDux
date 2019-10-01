import Foundation

/// A type of state that can be identified for tracking purposes.
///
/// This is typically used for entities stored in your state that might be accessed by id
/// or displayed in a `List` view.
public protocol IdentifiableState: StateType, Identifiable, Equatable where ID: Codable {}

extension IdentifiableState {

  public var hashValue: Int {
    return id.hashValue
  }

  /// The default hashing uses the hash from the `id` property.
  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }

}
