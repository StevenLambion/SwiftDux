import Foundation

/// Use the '+' operator to combine two or more reducers together.
public final class CompositeReducer<State, A, B>: Reducer where A: Reducer, B: Reducer, A.State == State, B.State == State {
  @usableFromInline
  internal var previousReducer: A

  @usableFromInline
  internal var nextReducer: B

  @usableFromInline internal init(previousReducer: A, nextReducer: B) {
    self.previousReducer = previousReducer
    self.nextReducer = nextReducer
  }

  @inlinable public func reduceAny(state: State, action: Action) -> State {
    nextReducer(state: previousReducer(state: state, action: action), action: action)
  }
}
