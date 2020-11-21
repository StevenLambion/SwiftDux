// Reduces the state of a store with the provided action to produce a new state.
internal final class ReducerMiddleware<State, RootReducer>: Middleware where RootReducer: Reducer, RootReducer.State == State {
  let reducer: CompositeReducer<State, StoreReducer<State>, RootReducer>
  let receivedState: (State) -> Void

  init(reducer: RootReducer, receivedState: @escaping (State) -> Void) {
    self.reducer = StoreReducer() + reducer
    self.receivedState = receivedState
  }

  @inlinable func run(store: StoreProxy<State>, action: Action) -> Action? {
    receivedState(reducer(state: store.state, action: action))
    return nil
  }
}
