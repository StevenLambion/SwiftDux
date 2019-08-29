# SwiftUI List Support

It's typical for an application to display an ordered list of domain objects to a user. This is simple enough to implement, but what if you need to perform an action on one of these objects using their id?

In this type of architecture, there's a commonly used pattern. In the state, you'd have a dictionary of objects by id and then an ordered array of the ids:

```swift
struct AppState : StateType {
  var books: [String:Book]
  var orderOfBooks: [String]

// get a book by id:
state.books["123"]

// Get all books in order:
state.orderOfBooks.map { state.books[$0] }
```

## Using `OrderedState<_>`

SwiftDux provides a prebuilt collection type to handle this pattern automatically called `OrderedState<_>`:

```swift
struct AppState : StateType {
  var books: OrderedState<Book>
}

// get a book by id:
state.books["123"]

// Get all books in order:
state.books.values
```

## Setting up the Reducer

The `OrderedState<_>` can be used like any other state. It also provides methods that map directly to events triggered by list views in SwiftUI. This allows actions to simply pass down the event parameters directly to the `OrderedState<_>` object. Below is an example of this.

```swift
enum AppAction {
  case setBooks([Book])
  case moveBooks(from: IndexSet, to: Int)
  case removeBooks(at: IndexSet)
}

class AppReducer : Reducer {

  reduce(state: AppState, action: AppAction) -> AppState {
    var state = state
    switch action {
      case .setBooks(let books):
        state.books = OrderedState(books)
      case .moveBooks(let indexSet, let index):
        state.books.move(from: indexSet, to: index)
      case .removeBooks(let indexSet):
        state.books.remove(at: indexSet)
    }
  }

}
```

## Setting Up the List View

Create a typical view that takes a list of items. Define callback closures for each kind of list event supported. `OrderedState<_>` can be used directly by List elements.

```swift
struct BookListView : View {

  @MappedState var state: AppState
  @MappedDispatch() var dispatch

  var body: some View {
    List {
      ForEach(state.books) { item in
        BookRow(item: item)
      }
      .onMove { self.dispatch(AppAction.moveBooks(from: $0, to: $1)) }
      .onDelete { self.dispatch(AppAction.removeBooks(at: $0)) }
    }
  }
}
```

```swift
struct RootView : View {

  var body: some View {
    BookListContainer.connect()
  }

}
```
