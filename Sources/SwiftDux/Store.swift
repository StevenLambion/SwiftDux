import Foundation
import Combine
import SwiftUI

public final class Store<State>: ActionSubscriber, BindableObject where State: StateType {
  public let didChange = PassthroughSubject<Void, Never>()
  private let didChangeWithActionSubject = PassthroughSubject<Action, Never>()
  
  public private(set) var state: State
  private let runReducer: (State, Action) -> State
  
  public init<R>(state: State, reducer: R) where R: Reducer, R.State == State {
    self.state = state
    self.runReducer = reducer.reduceAny
  }
  
  public func send(_ action: Action) {
    self.state = runReducer(self.state, action)
    self.didChangeWithActionSubject.send(action)
    self.didChange.send(())
  }
  
  public func map<A, T>(
    for action: A.Type,
    mapState: @escaping (State) -> T
  ) -> AnyPublisher<T, Never> where A: Action {
    return didChangeWithActionSubject
      .filter { $0 is A }
      .map { _ in mapState(self.state ) }
      .eraseToAnyPublisher()
  }
  
}

