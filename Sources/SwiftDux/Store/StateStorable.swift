import Combine
import Foundation

/// Represents  a storable container for a state object.
///
/// Extend this protocol to implement new methods for the Store<_> and StoreProxy<_>.
public protocol StateStorable {
  associatedtype State

  /// Retrieves the latest state from the store.
  var state: State { get }

  /// Emits after the specified action was sent to the store.
  var didChange: StorePublisher { get }
}

extension StateStorable {

  /// Publishes the state as it changes with a mapping function.
  ///
  /// - Parameter mapState: Maps the state to a more relevant props object.
  /// - Returns: A new publisher that emits non-duplicate updates.
  @inlinable public func publish<Props>(_ mapState: @escaping (State) -> Props)
    -> Publishers.RemoveDuplicates<Publishers.Map<Publishers.Merge<StorePublisher, Just<()>>, Props>> where Props: Equatable
  {
    didChange
      .merge(with: Just(()))
      .map { mapState(state) }
      .removeDuplicates()
  }
}

extension StateStorable where State: Equatable {

  /// Publishes the state as it changes.
  ///
  /// - Returns: A new publisher that emits non-duplicate updates.
  @inlinable public func publish() -> Publishers.RemoveDuplicates<Publishers.Map<Publishers.Merge<StorePublisher, Just<()>>, State>> {
    publish { $0 }
  }
}
