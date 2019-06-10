# SwiftDux

This is an experimental library to test out how a single store architecture could be implemented for SwiftUI.

## Purpose

The purpose of this library is to simplify the model layer into a single, manageable store. This would simplify data synchronization issues across different aspects of the application, such as with UIScenes.

## Implementation

This library is meant to be as small as possible by utilizing tools presented in SwiftUI and Combine. The store acts as a regular BIndableObject, but presents an API to map the application state to a new shape for each container view. It has optimizations such as the Connect view to help SwiftUI know when to update.

## Components

### StateType

### `StateType`

Represents your state as a struct or class object. The state is forced to be codable to provide easy persistence, and for external tooling. It's also a good idea to not place complex functionality into the state. It should be self-contained and transportable.

```swift
struct TodoListState: StateType, Hashable, Identifiable {
  var orderOfTodos: [String]
  var todoById: [String: TodoItemState]
}

struct TodoItemState: StateType, Hashable, Identifiable {
  var id: String
  var text: String
}
```

### `Action`

An action that updates your state. This should typically be an enum.

```swift
enum TodoListAction: Action {
  case addTodo(text: String)
  case removeTodos(at: IndexSet)
  case moveTodos(from: IndexSet, to: Int)
}
```

### `Reducer`

Updates a given state object when a relevant action is dispatched to it.

```swift
class TodoListReducer: Reducer {

  func reduce(state: TodoListState, action: TodoListAction) -> TodoListState {
    var state = state
    switch action {
    case .addTodo(let text):
      let id = UUID().uuidString
      state.todoById[id] = TodoItemState(id: id, text: text)
      state.orderOfTodos.insert(id, at: 0)
    case .removeTodos(let indexSet):
      indexSet.forEach { state.todoById.removeValue(forKey: state.orderOfTodos[$0]) }
      state.orderOfTodos.remove(at: indexSet)
    case .moveTodos(let indexSet, let index):
      let ids = Array(indexSet.map { state.orderOfTodos[$0] })
      state.orderOfTodos.remove(at: indexSet)
      state.orderOfTodos.insert(contentsOf: ids, at: index)
    }
    return state
  }

}
```

### `Store<State>`

Acts as the storage of your application's state and the dispatcher of actions. Your view subscribes to it for updates. Its mapping function or the Connect view should be used, so that SwiftUI only updates what's required.

```swift
// Somewhere in a UISceneDelegate class:

let store = Store(state: AppState.defaultState,reducer: AppReducer())

window.rootViewController = UIHostingController(
  rootView: RootView().environmentObject(store)
)
```

### `Connect<State, Action, Substate, Content>`

A view that subscribes to your state through the environment. It sends updates to a mapped version of the state to its contents when the state has been updated by a given action type.

```swift
struct RootView : View {

  var body: some View {
    NavigationView {
      Connect(with: mapStateToTodos, updateOn: AppAction.self) {
        TodoList(todos: $0, dispatcher: $1)
      }
    }
  }

  func mapStateToTodos(state: AppState) -> [TodoListState] {
    return state.orderOfTodos.map { state.todoById[$0]! }
  }

}
```

### `ActionDispatcher`

A protocol that simply dispatches any kind of action. The store implements this protocol to send actions to the root reducer of the application. The Connect view also provides a Dispatcher references as a convienence, so views don't need to reference the store.

```swift
struct TodoList : View {
  @State var editMode: EditMode = .active

  var todos: [TodoItemState]
  var dispatcher: ActionDispatcher

  var body: some View {
    List {
      ForEach(todos) { item in
        TodoItemRow(item: item)
      }
      .onDelete(perform: removeTodo)
      .onMove(perform: moveTodo)
    }
    .navigationBarTitle(Text("Todos"))
    .navigationBarItems(trailing:
      Button(action: addTodo) { Image(systemName: "plus").imageScale(.medium).padding() }
    )
    .environment(\.editMode, $editMode)
  }

  func addTodo() {
    dispatcher.send(TodoListAction.addTodo(withText: "New Todo Item"))
  }

  func removeTodo(at indexSet: IndexSet) {
    dispatcher.send(TodoListAction.removeTodos(at: indexSet))
  }

  func moveTodo(from indexSet: IndexSet, to index: Int) {
    dispatcher.send(TodoListAction.moveTodos( from: indexSet, to: index))
  }
}
```
