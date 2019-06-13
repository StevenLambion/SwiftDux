import Foundation
import SwiftUI
import SwiftDux

struct TodoListState: IdentifiableState, Hashable, Identifiable {
  var id: String
  var name: String
  var todos: OrderedState<String, TodoItemState>
}
