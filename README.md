# SwiftDux

> Predictable state management for SwiftUI applications.

[![Swift Version][swift-image]][swift-url]
![Platform Versions][ios-image]
[![License][license-image]][license-url]

This is still a work in progress.

## Introduction

This is yet another redux inspired state management solution for swift. It's built on top of the Combine framework with hooks for SwiftUI. This library helps build applications around an [elm-like archectiture](https://guide.elm-lang.org/architecture/) using a single, centralized state container. For more information about the architecture and this library, take a look at the [getting started guide](https://stevenlambion.github.io/SwiftDux/getting-started.html).

### Why another library?

As someone expierienced with Rx, React and Redux, I was excited to see the introduction of SwiftUI and the Combine framework. After a couple of days, I noticed a lot of people asking questions about how best to architect their SwiftUI applications. I had already begun work on my own pet application, so I've ripped out the "redux" portion and added it here as its own library in the hopes that it might help others.

There's more established libraries like [ReSwift](https://github.com/ReSwift/ReSwift/blob/master/README.md#example-projects) which may provide more functionality. Due to previous ABI instabilities and how easy it is to implement in Swift, I've always rolled my own.

### Why dux?

[Ducks](https://github.com/erikras/ducks-modular-redux) is an established and common way to organize your code into modules, so I thought it goes hand-in-hand with a library built around architecting an application. If you're new to tools like Redux and wonder how best to organize your files, ducks is a great option to begin with.

## Documentation

Visit the [documentation](https://stevenlambion.github.io/SwiftDux/getting-started.html) website.

## Installation

### Xcode 11

Use the new swift package manager integration to include the libary.

### Swift Package Manager

Include the library as a dependencies as shown below:

```swift
import PackageDescription

let package = Package(
  dependencies: [
    .Package(url: "https://github.com/StevenLambion/SwiftDux.git", majorVersion: 0, minor: 6)
  ]
)
```

## SwiftUI Examples

### Adding the SwiftDux store to the SwiftUI environment:

```swift
struct RootView : View {
  var store: Store<AppState>

  var body: some View {
    BookListView()
      .mapState(updateOn: BookAction.self) { (state: AppState) in state.books }
      .provideStore(store)
  }

}
```

### Use property wrappers to inject mapped states and the store dispatcher

```swift
struct BookListView : View {
  @MappedState var books: OrderedState<Book>
  @Dispatcher var send: SendAction

  var body: some View {
    List {
      ForEach(books) { item in
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
struct AuthorView : View {
  @MappedState author: AuthorState

  var body: some View {
    BookListView()
      .mapState(updateOn: BookAction.self) { (state: AuthorState) in state.books }
      .modifyActions(self.modifyBookActions)
  }

  func modifyBookActions(action: Action) -> Action? {
    if let action = action as? BookAction {
      return AuthorAction.routeBookAction(for: author.id, action)
    }
    return action
  }

}
```

## Known Issues

#### onAppear() doesn't update the view when dispatching actions

The built-in onAppear method does not trigger a view update. Use the provided onAppearAsync() instead.

#### @MappedState fails to find its state

Make sure the mapState() method is called in the correct environment scope. For example, a NavigationButton's destination is not in the same scope as the current content of the NavigationView even though the Button is declared inside it. To fix this, call the mapState() method directly on the NavigationView.

#### When using modifyActions() some views don't update properly.

When using modifyActions() both the original action and the new action are broadcasted. The new action updates the UI first. If the update affects any mapState() methods, a new environment object will be created for them. When the second action is fired the environment object of those mapped states haven't subscribed to the didChange publisher yet, so the action is ignored. This shouldn't be a problem, but SwiftUI also doesn't appear to refresh views when setting a new environment object to replace a previous one.

The current workaround is to use the optional "exceptWhen" parameter of the mapState() method on the parent view to ignore the modified action. This stops the recreation of the child mapState() methods, and reduces unneeded rerendering. 

[swift-image]: https://img.shields.io/badge/swift-5.1-orange.svg
[ios-image]: https://img.shields.io/badge/platforms-iOS%2013%20%7C%20macOS%2010.15%20%7C%20tvOS%2013%20%7C%20watchOS%206-222.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
