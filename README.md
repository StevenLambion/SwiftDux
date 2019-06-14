# SwiftDux

> Predictable state management for SwiftUI applications.

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]

<!-- [![Build Status][travis-image]][travis-url] -->

This is yet another redux inspired state management solution for swift. It's built on top of the Combine framework with an API to bind it to views within SwiftUI (think react-redux).

## Why

As someone expierienced with Rx, React and Redux, I was excited to see the introduction of SwiftUI and the Combine framework. As I began working on a pet project for a future SwiftUI application, I saw people asking about how best to structure their application using these new tools. This libary started out as internal code to my own app, but I've moved it to this repo in the hopes that it might help others get started.

There's many other great redux-like libaries such as ReSwift that have a bigger footing and probably more worthy features than this one.

## Features

- Redux inspired state management.
- Use publishers to dispatch actions.
- Use ActionPlans to wrapup complex workflows. (If redux-thunk used Combine)
- Inject state into SwiftUI views.
- Use OrderedState to automatically manage entities displayed in lists.
  - Provides methods that work directly with list events such as onMove and onDelete.
  - Lookup entities by id or index position.
  - Implements the MutableCollection protocol.
- State adheres to the Codable protocol.
  - Allows quick persistence and restoring of application state

## Installation

You can add this directly to Xcode 11 or add it to your project's `Package.swift` file

```swift
import PackageDescription

let package = Package(
  dependencies: [
    .Package(url: "https://github.com/StevenLambion/SwiftDux.git", majorVersion: 0, minor: 1)
  ]
)
```

## Documentation

[Click here for the documentation](https://stevenlambion.github.io/SwiftDux/)

## Usage

### 1. Create your state

```swift
import SwiftDux

struct AppState: StateType {
  /// OrderedState is a built-in type that acts as an ordered dictionary of substates.
  var todos: OrderedState<TodoState>
}

struct TodoState: IdentifiableState {
  vae id: String,
  var text: String
}
```

### 2. Create your reducer

```swift
import SwiftDux

enum TodoAction: Action {
  case addTodo(text: String)
  case removeTodos(at: IndexSet)
  case moveTodos(from: IndexSet, to: Int)
}

struct AppReducer: Reducer {

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

### 3. Create your store, and inject it into the environment

```swift
import SwiftDux

let store = Store(AppState(todos: OrderedState()), AppReducer())

window.rootViewController = UIHostingController(
  rootView: RootView().environmentObject(store)
)
```

### 4. Create your view separate from the state to make it more reusable and testable

```swift
import SwiftUI
import SwiftDux

struct Todos : View {
  @State var editMode: EditMode = .active

  var todos: [TodoItemState]
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
    ).environment(\.editMode, $editMode)
  }
}

```

### 5. Connect your state to the view

```swift
extension Todos {

  static func connected() -> some View {
    Store<AppState>.connect(updateOn: TodoAction.self) { state, dispatcher in
      Todos(
        todos: state.todos.value,
        onAddTodo: { dispatcher.send(AppAction.addTodo(text: "New Todo")) },
        onMoveTodos: { dispatcher.send(AppAction.moveTodos(from: $0, to: $1)) },
        onRemoveTodos: { dispatcher.send(AppAction.removeTodos(at: $0)) }
      )
    }
  }

}
```

### 6. Add the view to your RootView

```swift
import SwiftUI
import SwiftDux

struct RootView : View {

  var body: some View {
    NavigationView {
      Todos.connected()
    }
  }

}
```

[swift-image]: https://img.shields.io/badge/swift-5-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
