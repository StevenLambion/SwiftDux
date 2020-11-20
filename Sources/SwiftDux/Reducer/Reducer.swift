import Foundation

/// Performs an action on a given state and returns a whole new version.
///
/// A store is given a single root `Reducer`. As it's sent actions, it runs the reducer to
/// update the application's state.
public protocol Reducer {

  /// The type of state that the `Reducer` is able to mutate.
  associatedtype State

  /// The supported actions of a reducer.
  associatedtype ReducerAction

  /// Operates on the state with the reducer's own actions, returning a fresh new copy of the state.
  ///
  /// - Parameters
  ///   - state: The state to reduce.
  ///   - action: An action that the reducer is expected to perform on the state.
  /// - Returns: A new immutable state.
  func reduce(state: State, action: ReducerAction) -> State

  /// Send any kind of action to a reducer. The recuder will determine what it can do with
  /// the action.
  ///
  /// - Parameters
  ///   - state: The state to reduce
  ///   - action: Any kind of action.
  /// - Returns: A new immutable state
  func reduceAny(state: State, action: Action) -> State
}

extension Reducer {

  @inlinable public func callAsFunction(state: State, action: Action) -> State {
    reduceAny(state: state, action: action)
  }

  /// Default implementation. Returns the state without modifying it.
  ///
  /// - Parameters
  ///   - state: The state to reduce.
  ///   - action: An unknown action that a subreducer may support.
  /// - Returns: A new immutable state.
  @inlinable public func reduce(state: State, action: EmptyAction) -> State {
    state
  }

  /// Send any kind of action to a reducer. The recuder will determine what it can do with
  /// the action.
  ///
  /// - Parameters
  ///   - state: The state to reduce
  ///   - action: Any kind of action.
  /// - Returns: A new immutable state
  @inlinable public func reduceAny(state: State, action: Action) -> State {
    guard let reducerAction = action as? ReducerAction  else {
      return state
    }
    return reduce(state: state, action: reducerAction)
  }
}
