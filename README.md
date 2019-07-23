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

## Example

[Todo Example](https://github.com/StevenLambion/SwiftUI-Todo-Example)

## Installation

### Xcode 11

Use the new swift package manager integration to include the libary.

### Swift Package Manager

Include the library as a dependencies as shown below:

```swift
import PackageDescription

let package = Package(
  dependencies: [
    .Package(url: "https://github.com/StevenLambion/SwiftDux.git", majorVersion: 0, minor: 7)
  ]
)
```

## SwiftUI Examples

### Adding the SwiftDux store to the SwiftUI environment:

```swift
struct RootView : View {
  var store: Store<AppState>

  var body: some View {
    BookListView.connected()
      .mapState(updateOn: BookAction.self) { (state: AppState) in state.books }
      .provideStore(store)
  }

}
```

### Use property wrappers to inject mapped states and the store dispatcher

```swift
struct BookListView : View {
  var books: OrderedState<Book>
  var onRemoveBooks: (IndexSet) -> ()
  var onMoveBooks: (IndexSet, Int) -> ()

  var body: some View {
    List {
      ForEach(books) { item in
        BookRow(item: item)
      }
      .onMove(perform: self.onMoveBooks)
      .onDelete(perform: self.onRemoveBooks)
    }
  }
}

extension BookListView {

  static let connector = Connector<AppState> { $0 is BookAction }

  static func connected(authorId: String) -> some View {
    connector.mapToView { state, dispatcher in
      guard let author = state.authors[authorId] else {
        return nil
      }
      return BookListView(
        books: author.books,
        onRemoveBooks: { dispatcher.send(BookAction.removeBooks(at: $0)) }
        onMoveBooks: { dispatcher.send(BookAction.moveBooks(from: $0, to: $1)) }
      )
    }
  }

}
```

### Modify actions sent from child views

```swift
struct AuthorView : View {

  var body: some View {
    BookListView()
      .mapState(updateOn: BookAction.self) { (state: AuthorState) in state.books }
      .modifyActions(self.modifyBookActions)
  }

}

extension AuthorView {

  static let actionProxy = DispatcherProxy { action in
    if let action = action as? BookAction {
      return AuthorAction.routeBookAction(for: author.id, action)
    }
    return action
  }

  static let connector = Connector<AppState> { $0 is AuthorAction }

  static func connected(authorId: String) -> some View {
    connector.mapToView { state, dispatcher in
      guard let author = state.authors[authorId] else {
        return nil
      }
      return AuthorView(
        author: author
      )
      .modifier(actionProxy)
    }
  }

}
```

## Known Issues

#### onAppear() doesn't update the view when dispatching actions

The built-in onAppear method does not trigger a view update. Use the provided onAppearAsync() instead.

#### SwiftUI doesn't properly resubscribe to bindable objects after their initial creation.

~~Create all bindable objects outside of SwiftUI before binding them. Avoid recreating the objects.~~

Apple says this is fixed in beta 4. A quick test project appears to confirm it.

[swift-image]: https://img.shields.io/badge/swift-5.1-orange.svg
[ios-image]: https://img.shields.io/badge/platforms-iOS%2013%20%7C%20macOS%2010.15%20%7C%20tvOS%2013%20%7C%20watchOS%206-222.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
