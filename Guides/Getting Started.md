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

struct AppState : StateType {
  /// OrderedState is a built-in type that acts as an ordered dictionary of substates.
  var todos: OrderedState<TodoState>
}

struct TodoState : IdentifiableState {
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
protocol SettingsAction: Action {}

enum GeneralSettingsAction: SettingsAction {
  ...
}

enum NetworkSettingsAction: SettingsAction {
  ...
}
```

## Creating the Reducers

A reducer consumes actions to produce a new state. There's always a root reducer that consumes all actions. From here, it can delegate out to subreducers. Each reducer conforms to a single type of action.

The `Reducer` protocol has two primary methods of interest:

- `reduce(state:action:)` - For actions supported by the reducer.
- \*`reduceNext(state:action:)` - Dispatches an action to any subreducers

```swift
final class AppReducer : Reducer {

  func reduce(state: AppState, action: TodoAction) -> AppState {
    var state = state
    switch action {
    case .addTodo(let text):
      let id = UUID().uuidString
      state.todos.append(TodoItemState(id: id, text: text))
    case .removeTodos(let indexSet):
      state.todos.remove(at: indexSet)
    case .moveTodos(let indexSet, let index):
      state.todos.move(from: indexSet, to: index)
    }
    return state
  }

}
```

## Providing a Store

The store acts as the container of the state. In most cases, you simply need to initialize and provide the store to the root view of the application to get started. There's a convenient view modifier called `provideStore(_:)` to inject it into the environment

```swift
import SwiftDux

let store = Store(AppState(todos: OrderedState()), AppReducer())

window.rootViewController = UIHostingController(
  rootView: RootView().provideStore(store)
)
```

## Creating the View

The view layer of the application is the visual representation of the state. You should start out by creating what's known as a presentation view. This kind of view is decoupled from the state itself. Define local variables that will be populated at initialization as an injection point for the state. Use callback closures to later inject actions.

```swift
import SwiftUI

struct TodosView : View {
  @State var editMode: EditMode = .active

  // Will be populated by the state
  var todos: [TodoItemState]

  // These closures will be populated with action dispatchers.
  var onAddTodo: () -> ()
  var onMoveTodos: (IndexSet, Int) -> ()
  var onRemoveTodos: (IndexSet) -> ()

  var body: some View {
    List {
      ForEach(todos) { item in
        TodoItemRow(item: item)
      }
      .onDelete(perform: onRemoveTodos)
      .onMove(perform: onMoveTodos)
    }
    .environment(\.editMode, $editMode)
  }
}

```

## Connecting the State to the View

Using the static connect methods off of the `Store<_>` class, you can bind a view to the state and also dispatch actions. The connect method will automatically retrieve the store from the environment, and watch for changes to the state. When it detects a relevant change, it will update the view for you.

```swift
/// Update when the locally mapped state has changed:

func TodosContainer() -> some View {
  Store<AppState>.connect({ state.todos.value }) { todos, dispatcher in
    TodosView(
      todos: todos,
      onAddTodo: { dispatcher.send(AppAction.addTodo(text: "New Todo")) },
      onMoveTodos: { dispatcher.send(AppAction.moveTodos(from: $0, to: $1)) },
      onRemoveTodos: { dispatcher.send(AppAction.removeTodos(at: $0)) }
    )
  }
}

/// Update when an action has been dispatched:

func TodosContainer() -> some View {
  Store<AppState>.connect(updateOn: TodoAction.self) { state, dispatcher in
    TodosView(
      todos: state.todos.value,
      onAddTodo: { dispatcher.send(AppAction.addTodo(text: "New Todo")) },
      onMoveTodos: { dispatcher.send(AppAction.moveTodos(from: $0, to: $1)) },
      onRemoveTodos: { dispatcher.send(AppAction.removeTodos(at: $0)) }
    )
  }
}
```

The container view can be added like any other view:

```swift
struct RootView : View {

  var body: some View {
    TodosContainer()
  }

}
```
