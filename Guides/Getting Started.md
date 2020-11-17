# Getting Started

SwiftDux helps build SwiftUI-based applications around an [elm-like architecture](https://guide.elm-lang.org/architecture/) using a single, centralized state container. It has 4 basic constructs:

- **State** - An immutable, single source of truth within the application.
- **Action** - Describes a single change of the state.
- **Reducer** - Returns a new state by consuming the previous one with an action.
- **View** - The visual representation of the current state.

<div style="text-align:center">
  <img src="Guides/Images/architecture.jpg" width="400"/>
</div>

## State

The state is an immutable structure acting as the single source of truth within the application.

Below is an example of a todo app's state. It has a root `AppState` as well as an ordered list of `TodoState` objects.

```swift
import SwiftDux

typealias StateType = Equatable & Codable

struct AppState: StateType {
  todos: OrderedState<TodoItem>
}

struct TodoItem: StateType, Identifiable {
  var id: String,
  var text: String
}
```

## Actions

An action is a dispatched event to mutate the application's state. Swift's enum type is ideal for actions, but structs and classes could be used as well.

```swift
import SwiftDux

enum TodoAction: Action {
  case addTodo(text: String)
  case removeTodos(at: IndexSet)
  case moveTodos(from: IndexSet, to: Int)
}
```

## Reducers

A reducer consumes an action to produce a new state.

```swift
final class TodosReducer: Reducer {

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

## Store

The store manages the state and notifies the views of any updates.

```swift
import SwiftDux

let store = Store(
  state: AppState(todos: OrderedState()),
  reducer: AppReducer()
)

window.rootViewController = UIHostingController(
  rootView: RootView().provideStore(store)
)
```

## Middleware
SwiftDux supports middleware to expand its functionality. The SwiftDuxExtras module provides two built-in middleware to get started:

- `PersistStateMiddleware` Persists and restores the application state between sessions.
- `PrintActionMiddleware` prints out each dispatched action for debugging purposes.

```swift
import SwiftDux

let store = Store(
  state: AppState(todos: OrderedState()),
  reducer: AppReducer(),
  middleware: PrintActionMiddleware())
)

window.rootViewController = UIHostingController(
  rootView: RootView().provideStore(store)
)
```

## Composing Reducers, Actions, and Middleware
You may compose a set of reducers, actions, or middleware into an ordered chain using the '+' operator.

```swift
// Break up an application into smaller modules by composing reducers.
let rootReducer = AppReducer() + NavigationReducer()

// Add multiple middleware together.
let middleware = PrintActionMiddleware() + PersistStateMiddleware(JSONStatePersistor()

let store = Store(
  state: AppState(todos: OrderedState()),
  reducer: reducer,
  middleware: middleware
)
```

## ConnectableView

The `ConnectableView` protocol provides a slice of the application state to your views using the functions `map(state:)` or  `map(state:binder:)`. It automatically updates the view when the props value has changed.

```swift
struct TodosView: ConnectableView {
  struct Props: Equatable {
    var todos: [TodoItem]
  }

  func map(state: AppState) -> OrderedState<Todo>? {
    Props(todos: state.todos)
  }

  func body(props: OrderedState<Todo>): some View {
    List {
      ForEach(todos) { todo in
        TodoItemRow(item: todo)
      }
    }
  }
}
```

## ActionBinding<_>

Use the `map(state:binder:)` method on the `ConnectableView` protocol to bind an action to the props object. It can also be used to bind an updatable state value with an action.

```swift
struct TodosView: ConnectableView {
  struct Props: Equatable {
    var todos: [TodoItem]
    @ActionBinding var newTodoText: String
    @ActionBinding var addTodo: ()->()
  }

  func map(state: AppState, binder: ActionBinder) -> OrderedState<Todo>? {
    Props(
      todos: state.todos,
      newTodoText: binder.bind(state.newTodoText) { TodoAction.setNewTodoText($0) },
      addTodo: binder.bind { TodoAction.addTodo() }
    )
  }

  func body(props: OrderedState<Todo>): some View {
    List {
      TextField("New Todo", text: props.$newTodoText, onCommit: props.addTodo) 
      ForEach(todos) { todo in
        TodoItemRow(item: todo)
      }
    }
  }
}
```

## Action Plans
An `ActionPlan` is a special kind of action that can be used to group other actions together or perform any kind of async logic outside of a reducer. It's also useful for actions that may require information about the state before it can be dispatched.

```swift
/// Dispatch multiple actions after checking the current state of the application:

let plan = ActionPlan<AppState> { store in
  guard store.state.someValue == nil else { return }
  store.send(actionA)
  store.send(actionB)
  store.send(actionB)
}

/// Subscribe to services and return a publisher that sends actions to the store.

let plan = ActionPlan<AppState> { store in
  userLocationService
    .publisher
    .map { LocationAction.updateUserLocation($0) }
}
```

## Action Dispatching
You can access the `ActionDispatcher` of the store through the environment values. This allows you to dispatch actions from any view.

```swift
struct MyView: View {
  @Environment(\.actionDispatcher) private var dispatch

  var body: some View {
    MyForm.onAppear { dispatch(FormAction.prepare) }
  }
}
```

If it's an ActionPlan that's meant to be kept alive through a publisher, then you'll want to send it as a cancellable.

```swift
struct MyView: View {
  @Environment(\.actionDispatcher) private var dispatch
  @State private var cancellable: Cancellable? = nil

  var body: some View {
    MyForm.onAppear { cancellable = dispatch.sendAsCancellable(SecurityAction.whileAccessTokenIsValid) }
  }
}
```

The above can be further simplified by using the built-in `onAppear(dispatch:)` method instead. This method not only dispatches regular actions, but it automatically handles cancellable ones as well.

```swift
struct MyView: View {
  var body: some View {
    MyForm.onAppear(dispatch: SecurityAction.whileAccessTokenIsValid)
  }
}
```

## Previewing Connected Views
To preview a connected view by itself use the `provideStore(_:)` method inside the preview.

```swift
#if DEBUG
public enum TodoRowContainer_Previews: PreviewProvider {
  static var store: Store<TodoList> {
    Store(
      state: TodoList(
        id: "1",
        name: "TodoList",
        todos: .init([
          Todo(id: "1", text: "Get milk")
        ])
      ),
      reducer: TodosReducer()
    )
  }
  
  public static var previews: some View {
    TodoRowContainer(id: "1")
      .provideStore(store)
  }
  
}
#endif
```
