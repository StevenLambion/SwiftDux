import Foundation

/// Combines two reducers together. Use the `+` operator to create a combned reducer.
public final class CombinedReducer<State, A, B>: Reducer where A: Reducer, B: Reducer, A.State == State, B.State == State {
  @usableFromInline
  internal var previousReducer: A

  @usableFromInline
  internal var nextReducer: B

  @inlinable public init(previousReducer: A, nextReducer: B) {
    self.previousReducer = previousReducer
    self.nextReducer = nextReducer
  }

  @inlinable public func reduceAny(state: State, action: Action) -> State {
    nextReducer(state: previousReducer(state: state, action: action), action: action)
  }
}
