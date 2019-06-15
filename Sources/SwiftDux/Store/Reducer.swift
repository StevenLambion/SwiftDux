import Foundation

/// Performs an action on a given state and returns a whole new version.
///
/// A store is given a single root `Reducer`. As it's sent actions, it runs the reducer to
/// update the application's state. The reducer can have subreducers to separate code
/// out into modular parts.
///
/// For a reducer's own state and actions, implement the `reduce(state:action:)`.
/// For subreducers, implement the `reduceNext(state:action:)` method.
public protocol Reducer {
  associatedtype State: StateType
  associatedtype ReducerAction: Action
  
  /// Operates on the state with the reducer's own actions, returning a fresh new copy of the state.
  ///
  /// - Parameters
  ///   - state: The state to reduce
  ///   - action: An action that the reducer is expected to perform on the state.
  /// - Returns: A new immutable state
  func reduce(state: State, action: ReducerAction) -> State
  
  /// Delegates an action to a subreducer.
  ///
  /// - Parameters
  ///   - state: The state to reduce
  ///   - action: An unknown action that a subreducer may support.
  /// - Returns: A new immutable state
  func reduceNext(state: State, action: Action) -> State
  
}

extension Reducer {
  
  /// Default implementation for reducers that don't have their own actions.
  public func reduce(state: State, action: EmptyAction) -> State {
    return state
  }
  
  /// Default implementation for reducers that don't delegate to subreducers.
  public func reduceNext(state: State, action: Action) -> State {
    return state
  }
  
  /// Used externally by stores to send any kind of action to a reducer. It figures out
  /// if the reducer supports the provided action or not. If not, it delegates it to any
  /// subreducers.
  ///
  /// - Parameters
  ///   - state: The state to reduce
  ///   - action: Any kind of action.
  /// - Returns: A new immutable state
  public func reduceAny(state: State, action: Action) -> State {
    var state = state
    if let reducerAction = action as? ReducerAction {
      state = self.reduce(state: state, action: reducerAction)
    }
    return self.reduceNext(state: state, action: action)
  }
  
}
