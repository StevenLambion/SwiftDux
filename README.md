# SwiftDux

> Predictable state management for SwiftUI applications.

[![Swift Version][swift-image]][swift-url]
![Platform Versions][ios-image]
[![License][license-image]][license-url]

This is still a work in progress.

## Introduction

This is yet another redux inspired state management solution for swift. It's built on top of the Combine framework with hooks for SwiftUI. This library helps build applications around an [elm-like archectiture](https://guide.elm-lang.org/architecture/) using a single, centralized state container. For more information about the architecture and this library, take a look at the [getting started guide](https://stevenlambion.github.io/SwiftDux/getting-started.html).

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
    .Package(url: "https://github.com/StevenLambion/SwiftDux.git", majorVersion: 0, minor: 8)
  ]
)
```

## SwiftUI Examples

### Adding the SwiftDux store to the SwiftUI environment:

```swift
var store: Store<AppState>

...

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

### Reroute actions sent from child views

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

#### onAppear() doesn't update the view when dispatching actions

~~The built-in onAppear method does not trigger a view update. Use the provided onAppearAsync() instead.~~

It is now working correctly, but it only seems to run on views directly attached to a view controller under the hood. Typically this is the View directly passed to a NavigationLink. The onDisappear modifier is still not working. I'm unsure if it's some kind of optimization or incomplete functionality.

#### TextField caret doesn't keep up with text while typing

Starting with beta 5, using an ObservableObject with a TextField causes the caret to fall behind the text changes while typing too fast. This doesn't appear to effect @State properties, but I have been able to reproduce it using a simple ObservableObject based model. I submitted a ticket.

#### View doesn't update after it dispatches an action

~~See next issue below. For some reason, the observable object for dispatched actions is ignored by SwiftUI after its parent view has re-rendered in some cases. The observable object used by the state continues to work fine. I'm currently investigating the issue. The current fix is to manually implement the updateWhen(action:) function to rerender the view.~~

This has been fixed by changing the dispatch connection from an environment object to an environment value. I had previously tried this in earlier betas, but it didn't work as expected. It appears to be fixed in the current beta.

#### SwiftUI doesn't properly resubscribe to bindable objects after their initial creation.

~~Create all bindable objects outside of SwiftUI before binding them. Avoid recreating the objects.~~

~~Apple says this is fixed in beta 4. A quick test project appears to confirm it.~~

~~This appears to be almost fixed, but I'm still seeing it occur in one instance. I have not been able to verify if it's a bug in SwiftUI or a side-effect of its re-rendering behavior. I've submitted feedback to Apple.~~

I went the route of using an environment value, and that appears to have fixed the issue for this library.

[swift-image]: https://img.shields.io/badge/swift-5.1-orange.svg
[ios-image]: https://img.shields.io/badge/platforms-iOS%2013%20%7C%20macOS%2010.15%20%7C%20tvOS%2013%20%7C%20watchOS%206-222.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
