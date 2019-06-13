import Foundation
import SwiftDux

struct TestState: StateType {
  var todoLists: OrderedState<String, TodoListState>
}

extension TestState {
  
  static var defaultState: TestState {
    return TestState(
      todoLists: OrderedState(
        TodoListState(
          id: "123",
          name: "Shopping List",
          todos: OrderedState<String, TodoItemState>(
            TodoItemState(id: "1", text: "Eggs"),
            TodoItemState(id: "2", text: "Milk"),
            TodoItemState(id: "3", text: "Coffee")
          )
        )
      )
    )
  }
  
}
