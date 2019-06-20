# SwiftDux

> Predictable state management for SwiftUI applications.

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]

<!-- [![Build Status][travis-image]][travis-url] -->

## Introduction

This is yet another redux inspired state management solution for swift. It's built on top of the Combine framework with hooks for SwiftUI. This library helps build applications around an [elm-like archectiture](https://guide.elm-lang.org/architecture/) using a single, centralized state container.

- **State** - An immutable, single source of truth within the application.
- **Action** - Describes a state change.
- **Reducer** - Returns a new state by consuming the old one with an action.
- **View** - The visual representation of the current state.

<div style="text-align:center">
  <img src="./Guides/Images/architecture.jpg" width="400"/>
</div>

## Documentation

For a more indepth explanation, visit the [documentation](https://stevenlambion.github.io/SwiftDux/getting-started.html).

## Installation

### Xcode 11

Use the new swift package manager integration to include the libary.

### Package.swift

Include the library as a dependencies as shown below:

```swift
import PackageDescription

let package = Package(
  dependencies: [
    .Package(url: "https://github.com/StevenLambion/SwiftDux.git", majorVersion: 0, minor: 5)
  ]
)
```

## Examples in SwiftUI

### Add the store to the environment

```swift
struct RootView {
  var store: Store<AppState>

  var body: some View {
    BookListView()
      .mapState(updateOn: BookAction.self) { (state: AppState) in state.bookList }
      .provideStore(store)
  }

}
```

### Use property wrappers to inject mapped states and the store dispatcher

```swift
struct BookListView : View {
  @MappedState var bookList: BookListState
  @Dispatcher var send: SendAction

  var body: some View {
    List {
      ForEach(bookList.books.values) { item in
        BookRow(item: item)
      }
      .onMove { send(BookAction.moveBooks(from: $0, to: $1)) }
      .onDelete  { send(BookAction.removeBooks(at: $0)) }
    }
  }
}
```

### Modify actions sent from child views

```swift
struct AuthorView {
  @MappedState author: AuthorState

  var body: some View {
    BookListView()
      .mapState(updateOn: BookAction.self) { (state: AuthorState) in state.bookList }
      .modifyActions(self.modifyBookActions)
  }

  func modifyBookActions(action: Action) -> Action? {
    if let action = action as? BookAction {
      return AuthorAction.modifyAction(for: author.id, action)
    }
    return action
  }

}
```

## Motivation

As someone expierienced with Rx, React and Redux, I was excited to see the introduction of SwiftUI and the Combine framework. After a couple of days, I noticed a lot of people asking questions about how best to architect their SwiftUI applications. I had already begun work on my own pet application, so I've ripped out the "redux" portion and added it here as its own separate library in the hopes that it helps others.

There's more established libraries like [ReSwift](http://reswift.github.io/ReSwift/master/) which may provide more functionality. Due to previous ABI instabilities and how easy it is to implement in Swift, I've always rolled my own.

[swift-image]: https://img.shields.io/badge/swift-5.1-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com

## License

This project uses the [MIT](./LICENSE) license.
