# Persisting State

SwiftDux provides a state persistence API in the `SwiftDuxExtras` module. The API is designed to be flexible for use in a variety of cases. The two typical purposes are saving the application state for the user and providing the latest state object to a debugging tool.

## Create a state persistor

SwiftDuxExtras comes with a `StatePersistor` protocol to implement a new persistor type, but it also provides a concrete `JSONStatePersistor` class.

```swift
import SwiftDuxExtras

/// Initiate with no parameters to saves the state to a default location.

let persistor = JSONStatePersistor()

/// Initiate with `fileUrl` to saves the state to a a url of the local filesystem.

let persistor = JSONStatePersistor(fileUrl: appDataUrl)

/// Provide a custom `StatePersistenceLocation` for more flexibility.

let persistor = JSONStatePersistor(location: remoteLocation)
```

## Use middleware to set up state persistence

A state persistor can be used by itself, but SwiftDuxExtras provides a convenient middleware to do all the work for you.

```swift
import SwiftDuxExtras

let store = Store(
  state: AppState(),
  reducer: AppReducer(),
  middleware: [PersistStateMiddleware(JSONStatePersistor())]
)

```

With the above code, the application will automatically persist the state when there's changes. The state will automatically be restored on application launch.
