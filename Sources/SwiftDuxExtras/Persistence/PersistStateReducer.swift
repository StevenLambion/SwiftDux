import Foundation
import SwiftDux

/// Perform persist actions.
public enum PersistStateAction<State: StateType> : Action {
  case restore(state: State)
}

/// Reducer that performs persist actions on the state such as restoration.
public final class PersistStateReducer<State, R> : Reducer where R : Reducer, R.State == State {
  
  private let rootReducer: R
  
  /// Initiate the reducer as a wrapper over a root reducer.
  public init(_ rootReducer: R) {
    self.rootReducer = rootReducer
  }
  
  public func reduce(state: State, action: PersistStateAction<State>) -> State {
    switch action {
    case .restore(let restoredState):
      return restoredState
    }
  }
  
  public func reduceNext(state: State, action: Action) -> State {
    return rootReducer.reduceAny(state: state, action: action)
  }
  
}
