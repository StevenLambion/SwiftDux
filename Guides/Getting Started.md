# Getting Started

SwiftDux helps build SwiftUI-based applications around an [elm-like archectiture](https://guide.elm-lang.org/architecture/) using a single, centralized state container. It has 4 basic principles:

- **State** - An immutable, single source of truth within the application.
- **Action** - Describes a state change.
- **Reducer** - Returns a new state by consuming the old one with an action.
- **View** - The visual representation of the current state.

<div style="text-align:center">
  <img src="Guides/Images/architecture.jpg" width="400"/>
</div>

## Creating the State

The state is a single, immutable structure containing all stateful aspects of your application. It should be viewed as the single source of truth. Because its immutable, you should implement it using structs by default. Only when there's performance considerations, such as large datasets, should classes be used.

Below is an example of a todo app. It has a root `AppState` as well as an ordered list of `TodoState` objects. When storing entities in state, the `IdentifiableState` protocol can be used to help certain SwiftDux APIs work with them.

```swift
import SwiftDux

struct AppState : StateTyoe {
  todos: OrderedState<TodoItem>
}

struct TodoItem : IdentifiableState {
  vae id: String,
  var text: String
}
```

## Creating the Actions

An action is a declarative description of a future state change. They're typically dispatched from events in the application, such as a user clicking a button. Swift's enum type is the ideal type for actions in most cases.

```swift
import SwiftDux

enum TodoAction : Action {
  case addTodo(text: String)
  case removeTodos(at: IndexSet)
  case moveTodos(from: IndexSet, to: Int)
}
```

It can also be useful to categorize actions by using a shared protocol:

```swift
protocol SettingsAction : Action {}

enum GeneralSettingsAction : SettingsAction {
  ...
}

enum NetworkSettingsAction : SettingsAction {
  ...
}
```

## Creating the Reducers

A reducer consumes actions to produce a new state. There's always a root reducer that consumes all actions. From here, it can delegate out to subreducers. Each reducer conforms to a single type of action.

The `Reducer` protocol has two primary methods of interest:

- `reduce(state:action:)` - For actions supported by the reducer.
- \*`reduceNext(state:action:)` - Dispatches an action to any subreducers

```swift
final class TodosReducer : Reducer {

  func reduce(state: OrderedState<TodoItem>, action: TodoAction) -> OrderedState<TodoItem> {
    var state = state
    switch action {
    case .addTodo(let text):
      let id = UUID().uuidString
      state.append(TodoItemState(id: id, text: text))
    case .removeTodos(let indexSet):
      state.remove(at: indexSet)
    case .moveTodos(let indexSet, let index):
      state.move(from: indexSet, to: index)
    }
    return state
  }

}
```

```swift
final class AppReducer : Reducer {
  let todosReducer = TodosReducer()

  func reduceNext(state: AppState, action: TodoAction) -> AppState {
    State(
      todos: todosReducer.reduceAny(state.todos, action)
    )
  }

}
```

## Providing a Store

The store acts as the container of the state. In most cases, you simply need to initialize and provide the store to the root view of the application to get started. There's a convenient view modifier called `ProvideStore` to inject it into the environment.

```swift
import SwiftDux

let store = Store(AppState(todoList: TodoListState(todos: OrderedState())), AppReducer())

let storeProvider = StoreProvider(store: store)

window.rootViewController = UIHostingController(
  rootView: RootView().modifier(storeProvider)
)
```

## Creating the View

Use the `Connector` class to map the application state and dispatcher to a view. The connector acts as a reusable, stateless API to update a given view when an action is dispatched. Because it's referenced based it should be created statically outside of SwiftUI. A good spot is as a singleton in an extension of the view itself as shown below.

```swift
import SwiftUI

struct TodosView : View {

  // Will be populated by the state
  var todos: [TodoItemState]
  var onRemoveTodos: (IndexSet) -> ()
  var onMoveTodos: (IndexSet, Int) -> ()

  // These closures will be populated with action dispatchers.

  var body: some View {
    List {
      ForEach(todos) { item in
        TodoItemRow(item: item)
      }
      .onDelete(perform: self.onRemoveTodos)
      .onMove(perform: self.onMoveTodos)
    }
    .environment(\.editMode, $editMode)
  }
}

extension TodosView {

  static let connector = Connector<AppState> { $0 is TodoAction }

  static func connected() -> some View {
    connector.mapToView { state, dispatcher in
      TodosView(
        todos: state.todos,
        onRemoveTodos: { dispatcher.send(TodoAction.removeTodos(at: $0)) }
        onMoveTodos: { dispatcher.send(TodoAction.moveTodos(from: $0, to: $1)) }
      )
    }
  }

}

```

Add the container to the root view:

```swift
struct RootView : View {

  var body: some View {
    TodosView.connected()
  }

}
```
