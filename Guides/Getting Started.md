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

The state is a single, immutable structure acting as the single source of truth within the application.

Below is an example of a todo app's state. It has a root `AppState` as well as an ordered list of `TodoState` objects.

```swift
import SwiftDux

struct AppState: StateTyoe {
  todos: OrderedState<TodoItem>
}

struct TodoItem: IdentifiableState {
  var id: String,
  var text: String
}
```

## Actions

An action is a description of how the state will change. They're typically dispatched from events in the application. This could be a user interacting with the application or a service API receiving updates. Swift's enum type is ideal for actions, but structs and classes could be used as well.

```swift
import SwiftDux

enum TodoAction: Action {
  case addTodo(text: String)
  case removeTodos(at: IndexSet)
  case moveTodos(from: IndexSet, to: Int)
}
```

## Reducers

A reducer consumes an action to produce a new state. The `Reducer` protocol has two primary methods to override:

- `reduce(state:action:)` - For actions supported by the reducer.
- `reduceNext(state:action:)` - Dispatches an action to any sub-reducers. This method is optional.

```swift
final class TodosReducer: Reducer {

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

Here's an example of a root reducer dispatching to a subreducer.

```swift
final class AppReducer: Reducer {
  let todosReducer = TodosReducer()

  func reduceNext(state: AppState, action: TodoAction) -> AppState {
    State(
      todos: todosReducer.reduceAny(state.todos, action)
    )
  }

}
```

Reducers can also be combined together. This is useful when multiple root reducers are needed, such as two reducers from separate modules.

```swift
let combinedReducer = AppReducer + NavigationReducer
```

## Store

The store acts as the container of the state. It needs to be initialized with a default state and a root reducer. Then inject it into the application using the `provideStore(_:)` view modifier.

```swift
import SwiftDux

let store = Store(AppState(todos: OrderedState()), AppReducer())

window.rootViewController = UIHostingController(
  rootView: RootView().provideStore(store)
)
```

## Connectable View

The `ConnectableView` protocol provides a slice of the application state to your views using the functions `map(state:)` and `body(props:)`. The `@MappedDispatch` property wrapper injects an `ActionDispatcher` to send actions to the store.

```swift
struct TodosView: ConnectableView {
  @MappedDispatch() private var dispatch

  func map(state: AppState) -> OrderedState<Todo>? {
    state.todos
  }

  func body(props: OrderedState<Todo>): some View {
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

The view can later be placed like any other.

```swift
struct RootView: View {

  var body: some View {
    TodosView()
  }
}
```

## Passing Data to a Connectable View
In some cases, a connected view needs external information to map the state to its props, such as an identifier. Simply add any needed variables to your view, and access them in the mapping function.

```swift
struct TodoDetailsView: ConnectableView {
  var id: String

  func map(state: TodoList) -> Todo? {
    state[id]
  }
}

// Somewhere else in the view hierarchy:

TodoDetailsView(id: "123")
```

## ActionBinding<_>

SwiftUI has a focus on two-way bindings that connect to a single value source. To support updates through actions, SwiftDux provides a convenient API in the `ConnectableView` protocol using an `ActionBinder` object. Use the `map(state:binder:)` method on the protocol as shown below. It provides a value to the text field, and dispatches an action when the text value changes. It also binds a function to a dispatchable action.

```swift
struct LoginForm: View {

  struct Props: Equatable {
    @ActionBinding var email: String
    @ActionBinding var onSubmit: ()->()
  }

  func map(state: AppState, binder: ActionBinder) -> Props? {
    Props(
      email: binder.bind(state.loginForm.email) { 
        LoginFormAction.setEmail($0)
      },
      onSubmit: binder.bind(LoginFormAction.submit)
    )
  }

  func body(props: Props) -> some View {
    VStack {
      TextField("Email", text: $props.email)
      /* ... */
      Button(action: props.onSubmit) {
        Text("Submit")
      }
    }
  }
}
```

## Previewing Connected Views
To preview a connected view by itself, you can provide a store that contains the parent state and reducer it maps from. This preview is based on a view in the Todo List Example project. Make sure to add `provideStore(_:)` after the connect method.

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

## Action Plans
An `ActionPlan` is a special kind of action that can be used to group other actions together or perform any kind of async logic.

```swift
/// Dispatch multiple actions together synchronously:

let plan = ActionPlan<AppState> { store in
  store.send(actionA)
  store.send(actionB)
  store.send(actionB)
}

/// Perform async operations:

let plan = ActionPlan<AppState> { store in
  userLocationService.getLocation { location
    store.send(LocationAction.updateLocation(location))
  }
}

/// Subscribe to services and publish new actions to the store.

let plan = ActionPlan<AppState> { store, completed in
  userLocationService
    .subscribeToUpdates()
    .map { LocationAction.updateLocation($0) }
    .send(to: store, receivedCompletion: completed)
}

/// In a View, dispatch the plan like any other action:

dispatch(plan)
```

#

## Query External Services
Action plans can be used in conjunction with the `onAppear(dispatch:)` view modifier to connect to external data sources when a view appears. If the action plan returns a publisher, it will automatically cancel when the view disappears. Optionally, use `onAppear(dispatch:cancelOnDisappear:)` if the publisher should continue.

Action plans can also subscribe to the store. This is useful when the query needs to be refreshed if the application state changes. Rather than imperatively handling this by re-sending the action plan, it can be done more declaratively within it.

Here's an example of an action plan that queries for todos. It updates whenever the filter changes. It also debounces to reduce the amount of queries sent to the external services.

```swift
enum TodoListAction {
  ...
}

extension TodoListAction {

  static func getState(from store: Store<AppState>) -> some Publisher {
    Just(store.state).merge(with: store.didChange.map { _ in store.state })
  }

  static func queryTodos() -> ActionPlan<AppState> {
    ActionPlan<AppState> { store, completed in
      getState(from: store)
        .map { $0.filterBy }
        .removeDuplicates()
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .flatMap { filter in self.services.queryTodos(filter: filter) }
        .catch { _ in Just<[TodoItem]>([]) }
        .map { todos -> Action in TodoListAction.setTodos(todos) }
        .send(to: store, receivedCompletion: completed)
    }
  }
}

struct TodoListView: ConnectableView {

  func map(state: AppState) -> [TodoItem]? {
    state.todoList.items
  }

  func body(props: [TodoItem]) -> some View {
    renderTodos(todos: props)
      .onAppear(dispatch: TodoListAction.queryTodos())
  }

  // ...
}
```
