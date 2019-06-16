import SwiftUI
import Combine

/// A closure containing the content that will be connected to the application's state and an action dispatcher.
public typealias MapStateConnectContent<T, Dispatcher, Content> = (T, Dispatcher) -> Content
  where T : Equatable, Dispatcher : ActionPlanDispatcher, Content : View

extension Store {
  
  /// Connects the application state to a view.
  ///
  /// The connection maps the application's state to values that can be passed into a view. It then updates the view when
  /// the mapped value has changed. The store must be injected into the environment before this function can be used.
  /// To do this, use the `provideStore(_:)` modifier off of a View instance.
  ///```
  ///
  /// struct TodoListContainer: View {
  ///   ....
  /// }
  ///
  /// extension TodoListContainer {
  ///
  ///   static func connected(id: String) -> some View {
  ///     Store<AppState>.connect(mapState: { $0.todoLists[id].todos }) { todos, dispatcher in
  ///       TodoListContainer(
  ///         todos: todos,
  ///         onAdd: { dispatcher.send(TodoAction.addTodo($0) },
  ///         onRemove: { dispatcher.send(TodoAction.removeTodos($0) },
  ///         onMove: { dispatcher.send(TodoAction.moveTodos($0) }
  ///       )
  ///     }
  ///   }
  ///
  /// }
  /// ```
  public static func connect<T, Content>(
    _ mapState: @escaping (State)->T,
    wrapper: @escaping MapStateConnectContent<T, StoreActionDispatcher<State>, Content>
    ) -> some View where T : Equatable, Content : View {
    return MapStateConnect<State, T, Content>(mapState: mapState, wrapper: wrapper)
  }
  
}

/// Retrieves the current store and dispatcher from the environment and creates a `ConnectedStateUpdater` instance
/// to update the wrapped content when the specified action type is dispatched.
private struct MapStateConnect<State, T, Content> : View where T : Equatable, Content : View, State : StateType {
  @EnvironmentObject private var storeContext: StoreContext<State>
  
  private var mapState: (State)->T
  private var wrapper: MapStateConnectContent<T, StoreActionDispatcher<State>, Content>
  
  public init(mapState: @escaping (State)->T, wrapper: @escaping MapStateConnectContent<T, StoreActionDispatcher<State>, Content>) {
    self.mapState = mapState
    self.wrapper = wrapper
  }
  
  public var body: some View {
    MapStateInnerConnect(
      updater: MapStateConnectedStateUpdater<State, T>(
        store: storeContext.store,
        dispatcher: storeContext.dispatcher,
        mapState: mapState
      ),
      wrapper: self.wrapper
    )
  }
  
}

/// Binds to the `ConnectedStateUpdater` instance created in the `Connect` view to watch for updates.
private struct MapStateInnerConnect<State, T, Content>: View where T : Equatable, Content : View, State : StateType {
  @ObjectBinding private var updater: MapStateConnectedStateUpdater<State, T>
  
  private var wrapper: MapStateConnectContent<T, StoreActionDispatcher<State>, Content>
  
  init(updater: MapStateConnectedStateUpdater<State, T>, wrapper: @escaping MapStateConnectContent<T, StoreActionDispatcher<State>, Content>) {
    self.updater = updater
    self.wrapper = wrapper
  }
  
  public var body: some View {
    wrapper(updater.state, updater.dispatcher)
  }

}

/// The model object of the `Connect` view that updates the wrapped content when a specified action type is dispatched.
private class MapStateConnectedStateUpdater<State, T> : BindableObject where T : Equatable, State : StateType {
  var didChange = PassthroughSubject<Void, Never>()
  var state: T {
    didSet { didChange.send(()) }
  }
  let store: Store<State>
  let dispatcher: StoreActionDispatcher<State>
  
  private var cancel: AnyCancellable?
  
  init(store: Store<State>, dispatcher: StoreActionDispatcher<State>, mapState: @escaping (State)->T) {
    self.store = store
    self.dispatcher = dispatcher
    self.state = mapState(store.state)
    self.cancel = store.mapState(mapState).assign(to: \.state, on: self)
  }
  
}
