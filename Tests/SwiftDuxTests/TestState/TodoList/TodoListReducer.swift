import SwiftDux
import Foundation
import SwiftUI

enum TodoListAction: Action {
  case addTodo(toList: String, withText: String)
  case addTodo2(withText: String)
  case removeTodos(fromList: String, at: IndexSet)
  case moveTodos(inList: String, from: IndexSet, to: Int)
}

class TodoListReducer: Reducer {
  
  func reduce(state: TodoListState, action: TodoListAction) -> TodoListState {
    switch action {
    case .addTodo(_, let text): fallthrough
    case .addTodo2(let text):
      state.todos.prepend(TodoItemState(id: UUID().uuidString, text: text))
    case .removeTodos(_, let indexSet):
      state.todos.remove(at: indexSet)
    case .moveTodos(_, let indexSet, let index):
      state.todos.move(from: indexSet, to: index)
    }
    return state
  }
  
}
