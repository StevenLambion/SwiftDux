import Foundation

/// Use the '+' operator to combine two or more reducers together.
public final class CompositeReducer<State, A, B>: Reducer where A: Reducer, B: Reducer, A.State == State, B.State == State {
  @usableFromInline internal var previousReducer: A
  @usableFromInline internal var nextReducer: B

  @usableFromInline internal init(previousReducer: A, nextReducer: B) {
    self.previousReducer = previousReducer
    self.nextReducer = nextReducer
  }

  @inlinable public func reduceAny(state: State, action: Action) -> State {
    nextReducer(state: previousReducer(state: state, action: action), action: action)
  }
}

/// Compose two reducers together.
///
/// - Parameters:
///   - previousReducer: The first reducer to be called.
///   - nextReducer: The second reducer to be called.
/// - Returns: A combined reducer.
@inlinable public func + <R1, R2>(previousReducer: R1, _ nextReducer: R2) -> CompositeReducer<R1.State, R1, R2>
where R1: Reducer, R2: Reducer, R1.State == R2.State {
  CompositeReducer(previousReducer: previousReducer, nextReducer: nextReducer)
}
