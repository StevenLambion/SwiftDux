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

The store acts as the container of the state. Initialize the store with the application state and the reducer that will update it. Where you add the root view of the application, add the modifier `provideStore(_:)` to inject the store into the environment.

```swift
import SwiftDux

let store = Store(AppState(todos: OrderedState()), AppReducer())

window.rootViewController = UIHostingController(
  rootView: RootView().provideStore(store)
)
```

## Creating the View

In your view, use the `MappedState` and `MappedDispatch` to inject both the required state and a way to send an action to the store. When the view dispatches an action, it will update itself automatically.

```swift
struct TodosView {

  @MappedState private var todos: OrderedState<Todo>
  @MappedDispatch() private var dispatch

  var body: some View {
    List {
      ForEach(todos) { todo in
        TodoItemRow(item: todo)
      }
      .onDelete { self.dispatch(TodoAction.removeTodos(at: $0)) }
      .onMove { self.dispatch(TodoAction.moveTodos(from: $0, to: $1)) }
    }
  }

}
```

## Connecting State to the View

The easiest way to connect the application state to the view is through the `Connectable` and `ParameterizedConnectable` protocols.

Adhering to one of these protocols allows the view to map a parent state to the state required by it. It also adds a `connect()` or `connect(with:)` method to the view. This is how the state gets injected. Whereever the View is placed, you must always call the `connect()` method.

```swift
extension TodosView : Connectable {

  func map(state: AppState) -> OrderedState<Todo>? {
    state.todos
  }

}
```

Add the view to your application as shown below:

```swift
struct RootView : View {

  var body: some View {
    TodosView().connect()
  }

}
```
