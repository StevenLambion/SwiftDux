import Foundation
import Combine
import SwiftUI

public final class Store<State>: BindableObject where State: StateType {
  public private(set) var state: State
  private let runReducer: (State, Action) -> State
  
  private let didChangeWithActionSubject = PassthroughSubject<Action, Never>()
  public let didChangeWithAction: AnyPublisher<Action, Never>
  public let didChange: AnyPublisher<Void, Never>
  
  public init<R>(state: State, reducer: R) where R: Reducer, R.State == State {
    self.state = state
    self.runReducer = reducer.reduceAny
    self.didChangeWithAction = didChangeWithActionSubject.eraseToAnyPublisher()
    self.didChange = didChangeWithActionSubject.map { _ in () }.share().eraseToAnyPublisher()
  }
}
  
extension Store: StoreType {
  
  /// TODO - Look at batched "didChange" events when schedulers are better supported.
  public func send(_ action: Action) {
    self.state = runReducer(self.state, action)
    self.didChangeWithActionSubject.send(action)
  }
  
}
