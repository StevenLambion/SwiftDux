import Foundation
import Combine
import SwiftUI

/// The primary container of an application's state.
///
/// The store both contains and mutates the state through a provided reducer as it's sent actions.
/// Use the didChangeWithAction or didChange publishers to be notified of state changes.
///
/// The didChange publisher is provided primarily for usage by SwiftUI. To connect the state to the UI use the `Connect` view.
public final class Store<State>: BindableObject where State: StateType {
  
  /// The current state of the store. Use actions to mutate it.
  public private(set) var state: State
  private let runReducer: (State, Action) -> State
  
  private let didChangeWithActionSubject = PassthroughSubject<Action, Never>()
  
  /// Subscribe to this publisher to be notified of state changes caused by a particular action.
  public let didChangeWithAction: AnyPublisher<Action, Never>
  
  /// If you don't care what action caused a state change, use this publisher.
  public let didChange: AnyPublisher<Void, Never>
  
  public init<R>(state: State, reducer: R) where R: Reducer, R.State == State {
    self.state = state
    self.runReducer = reducer.reduceAny
    self.didChangeWithAction = didChangeWithActionSubject.eraseToAnyPublisher()
    self.didChange = PassthroughSubject<Void, Never>().eraseToAnyPublisher()
  }
}
  
extension Store: StoreType {
  
  /// TODO - Look at batched "didChange" events when schedulers are better supported.
  public func send(_ action: Action) {
    self.state = runReducer(self.state, action)
    self.didChangeWithActionSubject.send(action)
  }
  
}
