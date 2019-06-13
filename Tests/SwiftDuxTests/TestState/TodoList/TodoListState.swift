import Foundation
import SwiftUI
import SwiftDux

class TodoListState: IdentifiableState, Hashable, Identifiable {
  var id: String
  var name: String
  var todos: OrderedState<TodoItemState>
  
  init(id: String, name: String, todos: OrderedState<TodoItemState>) {
    self.id = id
    self.name = name
    self.todos = todos
  }
  
  static func == (lhs: TodoListState, rhs: TodoListState) -> Bool {
    lhs === rhs
  }
  
}
