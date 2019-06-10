import Foundation

public protocol Reducer {
  associatedtype State: StateType
  associatedtype ReducerAction: Action
  
  func reduce(state: State, action: ReducerAction) -> State
  
  func reduceNext(state: State, action: Action) -> State
  
}

extension Reducer {
  
  public func reduce(state: State, action: NoActions) -> State {
    return state
  }
  
  public func reduceNext(state: State, action: Action) -> State {
    return state
  }
  
  public func reduceAny(state: State, action: Action) -> State {
    guard let reducerAction = action as? ReducerAction else {
      return self.reduceNext(state: state, action: action)
    }
    return self.reduce(state: state, action: reducerAction)
  }
  
}
