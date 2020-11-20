import Combine
import Foundation

/// A concrete `ActionDispatcher` that can acts as a proxy.
public struct ActionDispatcherProxy: ActionDispatcher {
  @usableFromInline internal var sendBlock: SendAction
  @usableFromInline internal var sendAsCancellableBlock: SendCancellableAction
  
  
  /// Initiate a new BlockActionDispatcher.
  ///
  /// - Parameters:
  ///   - send: A closure to dispatch an action.
  ///   - sendAsCancellable: A closure to dispatch a cancellable action.
  public init(send: @escaping SendAction, sendAsCancellable: @escaping SendCancellableAction) {
    self.sendBlock = send
    self.sendAsCancellableBlock = sendAsCancellable
  }
  
  @inlinable  public func send(_ action: Action) {
    sendBlock(action)
  }
  
  @inlinable public func sendAsCancellable(_ action: Action) -> Cancellable {
    sendAsCancellableBlock(action)
  }
}
