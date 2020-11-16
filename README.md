# SwiftDux

> Predictable state management for SwiftUI applications.

[![Swift Version][swift-image]][swift-url]
![Platform Versions][ios-image]
[![Github workflow][github-workflow-image]](https://github.com/StevenLambion/SwiftDux/actions)
[![codecov][codecov-image]](https://codecov.io/gh/StevenLambion/SwiftDux)

SwiftDux is a redux and elm inspired state management solution built on top of Combine and SwiftUI. It allows you to build an application around predictable state using reactive, unidirectional data flows.

## Features

- __Redux__ inspired state management
- __SwiftUI__ Integration
- __Middleware__ support
- __Combine__ powered __Action Plans__ to perform asynchronous workflows

## Built-in Middleware

- `PersistStateMiddleware` Persists and restores the application state between sessions.
- `PrintActionMiddleware` prints out each dispatched action for debugging purposes.

# Installation

## Prerequisites
- Xcode 12+
- Swift 5.3+
- iOS 14+, macOS 11.0+, tvOS 14+, or watchOS 7+

## Install via Xcode:

Search for SwiftDux in Xcode's Swift Package Manager integration.

## Install via the Swift Package Manager:

```swift
import PackageDescription

let package = Package(
  dependencies: [
    .Package(url: "https://github.com/StevenLambion/SwiftDux.git", from: "2.0.0")
  ]
)
```

# Demo Application

Take a look at the [Todo Example App](https://github.com/StevenLambion/SwiftUI-Todo-Example) to see how SwiftDux works.

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

struct AppState: Equatable {
  todos: OrderedState<TodoItem>
}

struct TodoItem: Equatable, Identifiable {
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

Reducers can also be added together to form a composite reducer.

```swift
let combinedReducer = AppReducer + NavigationReducer
```

## Store

The store manages the state and notifies the views of any updates.

```swift
import SwiftDux

let store = Store(AppState(todos: OrderedState()), AppReducer())

window.rootViewController = UIHostingController(
  rootView: RootView().provideStore(store)
)
```

## ConnectableView

The `ConnectableView` protocol provides a slice of the application state to your views using the functions `map(state:)` or  `map(state:binder:)`.

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

Using the `map(state:binder:)` method on the `ConnectableView` protocol to bind an action to the props object. It can also be used to bind an updatable state value
with an action.

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
An `ActionPlan` is a special kind of action that can be used to group other actions together or perform any kind of async logic outside of a reducer.

```swift
/// Dispatch multiple actions together synchronously:

let plan = ActionPlan<AppState> { store in
  store.send(actionA)
  store.send(actionB)
  store.send(actionB)
}

/// Perform async operations:

let plan = ActionPlan<AppState> { store in
  userLocationService.getLocation { location in
    store.send(LocationAction.updateLocation(location))
  }
}

/// Subscribe to services and return a publisher that sends actions to the store.

let plan = ActionPlan<AppState> { store in
  userLocationService
    .publisher
    .map { LocationAction.updateLocation($0) }
}

/// In a View, dispatch the plan like any other action:

dispatch(plan)
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

[swift-image]: https://img.shields.io/badge/swift-5.2-orange.svg
[ios-image]: https://img.shields.io/badge/platforms-iOS%2013%20%7C%20macOS%2010.15%20%7C%20tvOS%2013%20%7C%20watchOS%206-222.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
[github-workflow-image]: https://github.com/StevenLambion/SwiftDux/workflows/build/badge.svg
[codecov-image]: https://codecov.io/gh/StevenLambion/SwiftDux/branch/master/graph/badge.svg
