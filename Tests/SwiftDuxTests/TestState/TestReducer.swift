import SwiftDux
import Foundation

enum TodoListsAction: Action {
  case addTodoList(name: String)
  case removeTodoLists(at: IndexSet)
  case moveTodoLists(from: IndexSet, to: Int)
}

enum TodosAction: Action {
  case addTodo(toList: String, withText: String)
  case removeTodos(fromList: String, at: IndexSet)
  case moveTodos(inList: String, from: IndexSet, to: Int)
  case doNothing
}

final class TodoListsReducer: Reducer {
  
  func reduce(state: AppState, action: TodoListsAction) -> AppState {
    var state = state
    switch action {
    case .addTodoList(let name):
        state.todoLists.append(
          TodoListState(id: UUID().uuidString, name: name, todos: OrderedState())
        )
    case .removeTodoLists(let indexSet):
      state.todoLists.remove(at: indexSet)
    case .moveTodoLists(let indexSet, let index):
      state.todoLists.move(from: indexSet, to: index)
    }
    return state
  }
}

final class TodosReducer<State>: Reducer where State: TodoListStateRoot {
  
  func reduce(state: State, action: TodosAction) -> State {
    let state = state
    switch action {
    case .addTodo(let id, let text):
    state.todoLists[id]?.todos.prepend(TodoItemState(id: UUID().uuidString, text: text))
    case .removeTodos(let id, let indexSet):
      state.todoLists[id]?.todos.remove(at: indexSet)
    case .moveTodos(let id, let indexSet, let index):
      state.todoLists[id]?.todos.move(from: indexSet, to: index)
    case .doNothing:
      break
    }
    return state
  }
}

let RootReducer = TodoListsReducer() + TodosReducer()
