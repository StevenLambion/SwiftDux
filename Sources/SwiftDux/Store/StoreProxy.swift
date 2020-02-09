import Combine
import Foundation

/// Creates a proxy of the store object for use by middleware.
///
/// Middleware may use the store proxy to retreive the current state, send actions,
/// continue to the next middleware, or subscribe to store changes. With the proxy,
/// middleware don't have to worry about retaining the store. Instead, the proxy provides
/// a safe API to access a weak reference to it.
public struct StoreProxy<State>: ActionDispatcher where State: StateType {

  /// Subscribe to state changes.
  @usableFromInline
  internal unowned var store: Store<State>

  /// Send an action to the next middleware
  @usableFromInline
  internal var modifyAction: ActionModifier?

  /// Send an action to the next middleware
  @usableFromInline
  internal var nextBlock: SendAction?

  @usableFromInline
  internal var doneBlock: (() -> Void)?

  /// Retrieves the latest state from the store.
  public var state: State {
    store.state
  }

  /// Emits after the specified action was sent to the store.
  public var didChange: AnyPublisher<Action, Never> {
    store.didChange
  }

  @inlinable internal init(store: Store<State>, modifyAction: ActionModifier? = nil, next: SendAction? = nil, done: (() -> Void)? = nil) {
    self.store = store
    self.modifyAction = modifyAction
    self.nextBlock = next
    self.doneBlock = done
  }

  @inlinable internal init(store: StoreProxy<State>, modifyAction: ActionModifier? = nil, next: SendAction? = nil, done: (() -> Void)? = nil) {
    self.store = store.store
    self.modifyAction = modifyAction.flatMap { outer in
      store.modifyAction.map { inner in
        { action in
          inner(action).flatMap { outer($0) }
        }
      } ?? outer
    }
    self.nextBlock = next
    self.doneBlock = done
  }

  /// Send an action to the store.
  /// - Parameter action: The action to send
  @inlinable public func send(_ action: Action) {
    let action = modifyAction.flatMap { $0(action) } ?? action
    store.send(action)
  }

  /// Use this in middleware to send an action to the next
  /// step in the pipeline. Outside of middleware, it does nothing.
  /// - Parameter action: The action to send
  @inlinable public func next(_ action: Action) {
    nextBlock?(action)
  }

  /// Used by action plans to tell the store that a publisher has completed or cancelled its work.
  /// Only use this if the action plan is not returning a publisher or subscribing via ActionSubscriber.
  /// This is not needed by action plans that don't return a cancellable.
  @inlinable public func done() {
    doneBlock?()
  }

  @inlinable public func proxy(modifyAction: ActionModifier?) -> ActionDispatcher {
    StoreProxy(store: self, modifyAction: modifyAction)
  }
}
