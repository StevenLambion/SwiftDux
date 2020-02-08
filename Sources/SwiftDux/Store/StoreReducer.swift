import Foundation

/// Actions performed for the store itself.
public enum StoreAction<State>: Action {

  /// Called at the initialization step of the store to allow reducers and middleware an oppertunity
  /// to set up configurations  Store actions may be dispatched at this stage, but other middleware
  /// and reducers might not be ready yet if they require any preparation themselves.
  case prepare

  /// Reset the entire state of the application.
  case reset(state: State)
}

internal final class StoreReducer<State>: Reducer where State: StateType {

  public func reduce(state: State, action: StoreAction<State>) -> State {
    switch action {
    case .reset(let newState):
      return newState
    default:
      return state
    }
  }
}
