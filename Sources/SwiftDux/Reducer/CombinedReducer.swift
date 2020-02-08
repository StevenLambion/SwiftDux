import Foundation

/// Combines two reducers together.
public final class CombinedReducer<State, A, B>: Reducer where A: Reducer, B: Reducer, A.State == State, B.State == State {
  private var previousReducer: A
  private var nextReducer: B
  
  internal init(previousReducer: A, nextReducer: B) {
    self.previousReducer = previousReducer
    self.nextReducer = nextReducer
  }

  public func reduceNext(state: State, action: Action) -> State {
    nextReducer(state: previousReducer(state: state, action: action), action: action)
  }
}
