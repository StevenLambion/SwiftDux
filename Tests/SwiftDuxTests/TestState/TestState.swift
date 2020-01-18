import Foundation
import SwiftDux

struct TestState: StateType {
  var todoLists: OrderedState<TodoListState>
}

extension TestState {
  
  static var defaultState: TestState {
    TestState(
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
