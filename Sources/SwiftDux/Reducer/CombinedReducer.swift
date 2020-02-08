import Foundation

/// Combines two reducers together.
public struct CombinedReducer<State, A, B>: Reducer where A: Reducer, B: Reducer, A.State == State, B.State == State {
  var previousReducer: A
  var nextReducer: B

  public func reduceNext(state: State, action: Action) -> State {
    nextReducer(state: previousReducer(state: state, action: action), action: action)
  }
}
