import Combine
import Foundation

/// The primary container of an application's state.
///
/// The store both contains and mutates the state through a provided reducer as it's sent actions.
/// Use the didChange publisher to be notified of changes.
public final class Store<State> where State: StateType {

  /// The current state of the store. Use actions to mutate it.
  public private(set) var state: State

  /// Subscribe for state changes. It emits the latest action sent to the store.
  public let didChange: AnyPublisher<Action, Never>

  private var reduceAction: SendAction = { _ in }

  internal let didChangeSubject = PassthroughSubject<Action, Never>()

  // swift-format-disable: ValidateDocumentationComments

  /// Creates a new store for the given state and reducer
  ///
  /// - Parameters
  ///   - state: The initial state of the store. A typically use case is to restore a previous application session with a persisted state object.
  ///   - reducer: A reducer that will mutate the store's state as actions are dispatched to it.
  ///   - middleware: One or more middleware plugins
  public init<R>(state: State, reducer: R, middleware: [Middleware] = []) where R: Reducer, R.State == State {
    let storeReducer = StoreReducer(reducer)
    self.state = state
    self.didChange = didChangeSubject.eraseToAnyPublisher()
    self.reduceAction = middleware.reversed().reduce(
      { [weak self] action in
        guard let self = self else { return }
        self.state = storeReducer.reduceAny(state: self.state, action: action)
        self.didChangeSubject.send(action)
      },
      { next, middleware in
        middleware.compile(store: StoreProxy(store: self, next: next))
      }
    )
    self.reduceAction(StoreAction<State>.prepare)
  }

  // swift-format-enable: ValidateDocumentationComments

}

extension Store: ActionDispatcher {

  // swift-format-disable: UseLetInEveryBoundCaseVariable

  /// Sends an action to the store to mutate its state.
  /// - Parameter action: The  action to mutate the state.
  public func send(_ action: Action) {
    switch action {
    case let action as ActionPlan<State>:
      send(actionPlan: action)
    case let modifiedAction as ModifiedAction:
      send(modifiedAction: modifiedAction)
    default:
      reduceAction(action)
    }
  }

  // swift-format-enable: UseLetInEveryBoundCaseVariable

  /// Handles the sending of normal action plans.
  private func send(actionPlan: ActionPlan<State>) {
    var cancellable: AnyCancellable? = nil
    let storeProxy = StoreProxy(
      store: self,
      done: {
        cancellable?.cancel()
        cancellable = nil
      }
    )
    cancellable = actionPlan.run(storeProxy) { [storeProxy] in
      storeProxy.done()
    }
    didChangeSubject.send(actionPlan)
  }

  private func send(modifiedAction: ModifiedAction) {
    send(modifiedAction.action)
    modifiedAction.previousActions.forEach { self.didChangeSubject.send($0) }
  }

  /// Create a new `ActionDispatcher` that acts as a proxy between the action sender and the store. It optionally allows actions to be
  /// modified or tracked.
  /// - Parameters
  ///   - modifyAction: An optional closure to modify the action before it continues up stream.
  ///   - sentAction: Called directly after an action was sent up stream.
  /// - Returns: a new action dispatcher.
  public func proxy(modifyAction: ActionModifier? = nil, sentAction: ((Action) -> Void)? = nil) -> ActionDispatcher {
    StoreActionDispatcher(
      upstream: self,
      modifyAction: modifyAction,
      sentAction: sentAction
    )
  }

}

extension Publisher where Output == Action, Failure == Never {

  /// Subscribe to a publisher of actions, and send the results to a store.
  /// - Parameters:
  ///   - store: A store proxy
  ///   - receivedCompletion: An optional block called when the publisher completes.
  /// - Returns: A cancellable to unsubscribe.
  public func send<State>(to store: Store<State>, receivedCompletion: ActionSubscriber.ReceivedCompletion? = nil) -> AnyCancellable
  where State: StateType {
    self.send(to: store, receivedCompletion: receivedCompletion)
  }

  /// Subscribe to a publisher of actions, and send the results to a store.
  /// - Parameters:
  ///   - store: A store proxy
  ///   - receivedCompletion: An optional block called when the publisher completes.
  /// - Returns: A cancellable to unsubscribe.
  public func send<State>(to store: StoreProxy<State>, receivedCompletion: ActionSubscriber.ReceivedCompletion? = nil) -> AnyCancellable
  where State: StateType {
    let cancellable = self.send(to: store.send, receivedCompletion: receivedCompletion)
    return AnyCancellable { [cancellable] in
      cancellable.cancel()
      store.done()
    }
  }
}
