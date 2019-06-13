import Foundation

public protocol IdentifiableStateType: StateType, Hashable {
  associatedtype Id: Comparable & Hashable & Codable
  
  var id: Id { get set }
}

extension IdentifiableStateType {
  
  public var hashValue: Int {
    return id.hashValue
  }
  
  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }
  
}

