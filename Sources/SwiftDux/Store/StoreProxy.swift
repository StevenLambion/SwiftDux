import Combine
import Foundation

/// Creates a proxy of the store object for use by middleware.
///
/// Middleware may use the store proxy to retreive the current state, send actions,
/// continue to the next middleware, or subscribe to store changes. With the proxy,
/// middleware don't have to worry about retaining the store. Instead, the proxy provides
/// a safe API to access a weak reference to it.
public struct StoreProxy<State>: ActionDispatcher {

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

  /// Send an action to the store.
  /// - Parameter action: The action to send
  @inlinable public func send(_ action: Action) {
    dispatcher.send(action)
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
}
