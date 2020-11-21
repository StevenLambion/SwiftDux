import Combine
import Foundation

/// Represents  a storable container for a state object.
///
/// Extend this protocol to implement new methods for the Store<_> and StoreProxy<_> types.
public protocol StateStorable {
  /// The type of the stored state object.
  associatedtype State

  /// The latest state of the store.
  var state: State { get }

  /// Emits after the state has been changed.
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

extension StateStorable where Self: ActionDispatcher {

  /// Create a proxy of the `StateStorable` for a given type or protocol.
  ///
  /// - Parameter dispatcher: An optional dispatcher for the proxy.
  /// - Returns: A proxy object if the state type matches, otherwise nil.
  @inlinable public func proxy(dispatcher: ActionDispatcher? = nil) -> StoreProxy<State> {
    StoreProxy<State>(
      getState: { state },
      didChange: didChange,
      dispatcher: dispatcher ?? self
    )
  }

  /// Create a proxy of the `StateStorable` for a given type or protocol.
  ///
  /// - Parameters:
  ///   - stateType: The type of state for the proxy. This must be a type that the store adheres to.
  ///   - dispatcher: An optional dispatcher for the proxy.
  /// - Returns: A proxy object if the state type matches, otherwise nil.
  @inlinable public func proxy<T>(for stateType: T.Type, dispatcher: ActionDispatcher? = nil) -> StoreProxy<T>? {
    guard state is T else { return nil }
    return StoreProxy<T>(
      getState: { state as! T },
      didChange: didChange,
      dispatcher: dispatcher ?? self
    )
  }
}
