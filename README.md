# SwiftDux

> Predictable state management for SwiftUI applications.

[![Swift Version][swift-image]][swift-url]
![Platform Versions][ios-image]
[![License][license-image]][license-url]

This is still a work in progress.

## Introduction

This is yet another redux inspired state management solution for swift. It's built on top of the Combine framework with hooks for SwiftUI. This library helps build applications around an [elm-like architecture](https://guide.elm-lang.org/architecture/) using a single, centralized state container. For more information about the architecture and this library, take a look at the [getting started guide](https://stevenlambion.github.io/SwiftDux/getting-started.html).

This library is designed around Combine and SwiftUI. For a more established library that doesn't require iOS 13, check out [ReSwift](https://github.com/ReSwift/ReSwift).

## Top Features

### Redux-like State Management.

- `Middleware` support
- `ActionPlan` for action-based workflows.
  - Use them like action creators in Redux.
  - Supports async operations.
  - Supports returning a Combine publisher
- `OrderedState<_>` for managing an ordered collection of state objects.

### SwiftUI Integration.

- `@MappedState` injects state into a view.
- `@MappedDispatch` let's views dispatch actions.
  - Automatically updates the view after each sent action.
  - Supports action plans.
- `Connectable` API connects and maps the application state into SwiftUI.
- `onAction(perform:)` allows you to track or modify dispatched actions.
- `OrderedState<_>` has direct support of List views.

### Extras

- `PersistStateMiddleware` to automatically persist and restore application state.
- `PrintActionMiddleware` Simple middleware that prints out each dispatched action for debugging.

## Documentation

Visit the [documentation](https://stevenlambion.github.io/SwiftDux/getting-started.html) website.

## Example

[Todo Example App](https://github.com/StevenLambion/SwiftUI-Todo-Example)

## Installation

### Xcode 11

Use the new swift package manager integration to include the library.

### Swift Package Manager

Include the library as a dependencies as shown below:

```swift
import PackageDescription

let package = Package(
  dependencies: [
    .Package(url: "https://github.com/StevenLambion/SwiftDux.git", majorVersion: 0, minor: 11)
  ]
)
```

## SwiftUI Examples

### Adding the SwiftDux store to the SwiftUI environment:

```swift
/// Basic store example

var store = Store(state: AppState(), reducer: AppReducer())

/// Advanced store example with middleware

var store = Store(
  state: AppState(),
  reducer: AppReducer(),
  middleware: [
    PrintActionMiddleware(),
    PersistStateMiddleware(JSONStatePersistor())
  ]
)

/// Inject the store

RootView().provideStore(store)
```

### Inject the state into a view using property wrappers:

```swift
struct BookListView : View {

  @MappedState private var books: OrderedState<Book>
  @MappedDispatch() private var dispatch

  var body: some View {
    List {
      ForEach(books) { book in
        BookRow(title: book.title)
      }
      .onMove { self.dispatch(BookAction.move(from: $0, to: $1)) }
      .onDelete { self.dispatch(BookAction.delete(at: $0)) }
    }
  }
}

/// Adhere to the Connectable protocol to map a parent state to
/// one that the view requires.

extension BookListView : Connectable {

  func map(state: AppState) -> OrderedState<Book> {
    state.books
  }

}
```

### Update a view whenever an action is dispatched to the store.

```swift
extension BookListView : Connectable {

  /// Views always update when dispatching an action, but
  /// sometimes you may want it to update every time a given
  /// action is sent to the store.

  updateWhen(action: Action) -> Bool {
    action is BookStatusAction
  }

  func map(state: AppState) -> OrderedState<Book> {
    state.books
  }

}
```

### Modify actions sent from child views before they get to the store

```swift
struct AuthorView : View {

  @MappedState private var author: Author

  var body: some View {
    BookListContainer()
      .connect(with: author.id)
      .onAction { [author] action in
        if let action = action as? BookAction {
          return AuthorAction.routeBookAction(for: author.id, action)
        }
        return action
      }
  }

}
```

## Known issues in SwiftUI

#### @MappedDispatch is requiring an explicit type

You must provide parentheses at the end of @MappedDispatch to initialize it without requiring an explicit type: `@MappedDispatch() var dispatch`

#### TextField caret doesn't keep up with text while typing

Starting with beta 5, using an ObservableObject with a TextField causes the caret to fall behind the text changes while typing too fast. This doesn't appear to effect @State properties, but I have been able to reproduce it using a simple ObservableObject based model. I submitted a ticket.

[swift-image]: https://img.shields.io/badge/swift-5.1-orange.svg
[ios-image]: https://img.shields.io/badge/platforms-iOS%2013%20%7C%20macOS%2010.15%20%7C%20tvOS%2013%20%7C%20watchOS%206-222.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
