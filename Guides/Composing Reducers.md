# Composing Reducers

To comprehend large and complex applications, you need to structure the state into bite-sized components that can be composed together. Below is an example of an application state with 3 levels: the app state that contains a list of authors, an author state that contains a list of books, and a book state.

Each part should contain their own separate actions and reducers if needed.

```swift
struct AppState : StateType {
  var authors: OrderedState<Author>
}

struct Author : IdentifiableState {
  var id: String
  var title: String
  var books: OrderedState<Book>
}

struct Book : IdentifiableState {
  id: String,
  name: String
}
```

The `AppReducer` is the root reducer of the application. It must accept and dispatch all actions to the rest of the reducers. It does this by implementing `reduceNext(state:action:)`

```swift
class AppReducer : Reducer {

  let authorReducer: AuthorReducer()

  // Reduce actions that the app reducer supports:

  reduce(state: AppState, action: AppAction) -> AppState {
    var state = state
    switch action {
      case .addAuthor(let book):
        state.authors.append(book)
      case .removeAuthor(let id):
        state.authors.remove(byId: id)
    }
  }

  // Delegate all other actions to the subreducers.

  reduceNext(state: AppState, action: Action) -> AppState {
    AppState(
      authors: state.authors.mapValues {
        self.authorReducer.reduceAny(state: $0, action action)
      }
    )
  }

}
```

Here, the author reducer accept only its own slice of the overall state.

```swift
class AuthorReducer : Reducer {

  reduce(state: Author, action: AuthorAction) -> Author {
    var state = state
    switch action {
      case .addBook(let book):
        state.books.append(book)
      case .removeBook(let id):
        state.books.remove(byId: id)
    }
  }

}
```
