import Combine
import Foundation

/// Creates a proxy of the store object for use by middleware.
///
/// Middleware may use the store proxy to retreive the current state, send actions,
/// continue to the next middleware, or subscribe to store changes. With the proxy,
/// middleware don't have to worry about retaining the store. Instead, the proxy provides
/// a safe API to access a weak reference to it.
public struct StoreProxy<State>: StateStorable, ActionDispatcher {

  @usableFromInline
  internal var getState: () -> State

  /// Emits after the specified action was sent to the store.
  public var didChange: StorePublisher

  /// Send an action to the next middleware
  @usableFromInline
  internal var dispatcher: ActionDispatcher

  /// Send an action to the next middleware
  @usableFromInline
  internal var nextBlock: SendAction?

  @usableFromInline
  internal var doneBlock: (() -> Void)?

  /// Retrieves the latest state from the store.
  public var state: State {
    getState()
  }

  @inlinable internal init(
    getState: @escaping () -> State,
    didChange: StorePublisher,
    dispatcher: ActionDispatcher,
    next: SendAction? = nil,
    done: (() -> Void)? = nil
  ) {
    self.getState = getState
    self.didChange = didChange
    self.dispatcher = dispatcher
    self.nextBlock = next
    self.doneBlock = done
  }

  @inlinable internal init(proxy: StoreProxy<State>, dispatcher: ActionDispatcher? = nil, next: SendAction? = nil, done: (() -> Void)? = nil) {
    self.getState = proxy.getState
    self.didChange = proxy.didChange
    self.dispatcher = dispatcher ?? proxy
    self.nextBlock = next ?? proxy.nextBlock
    self.doneBlock = done ?? proxy.doneBlock
  }

  /// Sends an action to mutate the application state.
  ///
  /// - Parameter action: The action to send
  @inlinable public func send(_ action: Action) {
    dispatcher.send(action)
  }

  /// Passes an action to the next middleware.
  ///
  /// Outside of the middleware pipeline this method does nothing.
  /// - Parameter action: The action to send
  @inlinable public func next(_ action: Action) {
    nextBlock?(action)
  }

  /// Used by runnable action to tell the store that a publisher has completed or cancelled its work.
  ///
  /// Only use this if the action returns a cancellable object without using ActionSubscriber.
  @inlinable public func done() {
    doneBlock?()
  }
}
