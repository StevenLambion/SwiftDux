import Foundation
import SwiftDux

func configureStore(state: AppState = AppState.defaultState) -> Store<AppState> {
  Store(state: state, reducer: TodoListsReducer() + TodosReducer())
}
