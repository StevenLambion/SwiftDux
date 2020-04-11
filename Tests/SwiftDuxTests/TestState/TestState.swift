import Foundation
import SwiftDux

final class TodoListState: IdentifiableState {
  var id: String
  var name: String
  var todos: OrderedState<TodoItemState>
  
  init(id: String, name: String, todos: OrderedState<TodoItemState>) {
    self.id = id
    self.name = name
    self.todos = todos
  }

  static func == (lhs: TodoListState, rhs: TodoListState) -> Bool {
    lhs.id == rhs.id
  }
}

struct TodoItemState: IdentifiableState, Hashable, Identifiable {
  var id: String
  var text: String
}

protocol TodoListStateRoot {
  var todoLists: OrderedState<TodoListState> { get set }
}

struct AppState: StateType, TodoListStateRoot {
  var todoLists: OrderedState<TodoListState>
}

extension AppState {
  
  static var defaultState: AppState {
    AppState(
      todoLists: OrderedState(
        TodoListState(
          id: "123",
          name: "Shopping List",
          todos: OrderedState<TodoItemState>(
            TodoItemState(id: "1", text: "Eggs"),
            TodoItemState(id: "2", text: "Milk"),
            TodoItemState(id: "3", text: "Coffee")
          )
        )
      )
    )
  }
}
