import Foundation

/// Actions performed for the store itself.
public enum StoreAction<State> : Action {
  
  /// Called at the initialization step of the store to allow reducers and middleware an oppertunity
  /// to set up configurations  Store actions may be dispatched at this stage, but other middleware
  /// and reducers might not be ready yet if they require any preparation themselves.
  case prepare
  
  /// Reset the entire state of the application.
  case reset(state: State)
}

internal final class StoreReducer<State, R> : Reducer where R : Reducer, R.State == State {
  
  private let rootReducer: R
  
  /// Initiate the reducer as a wrapper over a root reducer.
  public init(_ rootReducer: R) {
    self.rootReducer = rootReducer
  }
  
  public func reduce(state: State, action: StoreAction<State>) -> State {
    switch action {
    case .reset(let newState):
      return newState
    default:
      return state
    }
  }
  
  public func reduceNext(state: State, action: Action) -> State {
    return rootReducer.reduceAny(state: state, action: action)
  }
  
}
