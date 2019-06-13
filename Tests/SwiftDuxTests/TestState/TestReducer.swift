import SwiftDux
import Foundation

enum TestAction: Action {
  case addTodoList(name: String)
  case removeTodoLists(at: IndexSet)
  case moveTodoLists(from: IndexSet, to: Int)
}

class TestReducer: Reducer {
  
  let todoListReducer = TodoListReducer()
  
  func reduce(state: TestState, action: TestAction) -> TestState {
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
  
  func reduceNext(state: TestState, action: Action) -> TestState {
    var state = state
    switch action {
    case TodoListAction.addTodo(let id, _): fallthrough
    case TodoListAction.removeTodos(let id, _): fallthrough
      case TodoListAction.moveTodos(let id, _, _):
      state = routeToTodoList(state: state, id: id, action: action)
    default: break
    }
    return state
  }
  
  func routeToTodoList(state: TestState, id: String, action: Action) -> TestState {
    var state = state
    let todo = state.todoLists[id]
    state.todoLists[id] = todoListReducer.reduceAny(state: todo, action: action)
    return state
  }
  
}
