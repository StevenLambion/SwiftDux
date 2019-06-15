import Foundation
import Combine

/// The primary container of an application's state.
///
/// The store both contains and mutates the state through a provided reducer as it's sent actions.
/// Use the didChangeWithAction or didChange publishers to be notified of state changes.
///
/// The didChange publisher is provided primarily for usage by SwiftUI. To connect the state to the UI use the `Connect` view.
public final class Store<State> where State : StateType {
  
  /// The current state of the store. Use actions to mutate it.
  public private(set) var state: State
  private let runReducer: (State, Action) -> State
  
  private let didChangeWithActionSubject = PassthroughSubject<Action, Never>()
  
  /// Subscribe to this publisher to be notified of state changes caused by a particular action.
  public let didChangeWithAction: AnyPublisher<Action, Never>
  
  /// Creates a new store for the given state and reducer
  ///
  /// - Parameters
  ///   - state: The initial state of the store. A typically use case is to restore a previous application session with a persisted state object.
  ///   - reducer: A reducer that will mutate the store's state as actions are dispatched to it.
  public init<R>(state: State, reducer: R) where R : Reducer, R.State == State {
    self.state = state
    self.runReducer = reducer.reduceAny
    self.didChangeWithAction = didChangeWithActionSubject.eraseToAnyPublisher()
  }
}
  
extension Store : StoreType {
  
  /// Sends an action to the store to mutate its state.
  /// - Parameter action: The  action to mutate the state.
  public func send(_ action: Action) {
    self.state = runReducer(self.state, action)
    self.didChangeWithActionSubject.send(action)
  }
  
}

extension Store {
  
  func dispatcher(modifyAction: StoreDispatcher<State>.ActionModifier? = nil) -> StoreDispatcher<State> {
    return StoreDispatcher(
      upstream: self,
      upstreamActionSubject: self.didChangeWithActionSubject,
      modifyAction: modifyAction
    )
  }
  
}
