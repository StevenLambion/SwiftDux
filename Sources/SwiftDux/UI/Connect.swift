import SwiftUI
import Combine

/// A closure containing the content that will be connected to the application's state and an action dispatcher.
public typealias ConnectedContent<Dispatcher, Content> = (Dispatcher.State, Dispatcher) -> Content
  where Dispatcher : ActionPlanDispatcher, Content : View

extension Store {
  
  /// Connects the application state to a view.
  ///
  /// The connection maps the application's state to values that can be passed into a view. It then updates the view when
  /// a relevant action type is performed.
  ///```
  /// struct TodoListContainer: View {
  ///   ....
  /// }
  ///
  /// extension TodoListContainer {
  ///
  ///   static func connected() -> some View {
  ///     Store<AppState>.connect(updateOn: TodoAction.self) { todos, dispatcher in
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
  public static func connect<TypeOfAction, Content>(
    updateOn typeOfAction: TypeOfAction.Type,
    wrapper: @escaping ConnectedContent<Store<State>, Content>
  ) -> some View where TypeOfAction : Action, Content : View {
    return Connect<State, TypeOfAction, Content>(updateOn: typeOfAction, wrapper: wrapper)
  }
  
}

/// Retrieves the current store and dispatcher from the environment and creates a `ConnectedStateUpdater` instance
/// to update the wrapped content when the specified action type is dispatched.
private struct Connect<State, TypeOfAction, Content> : View where Content : View, State : StateType, TypeOfAction : Action {
  @EnvironmentObject private var storeContext: StoreContext<State>
  
  private var typeOfAction: TypeOfAction.Type
  private var wrapper: ConnectedContent<Store<State>, Content>
  
  public init(updateOn typeOfAction: TypeOfAction.Type, wrapper: @escaping ConnectedContent<Store<State>, Content>) {
    self.typeOfAction = typeOfAction
    self.wrapper = wrapper
  }
  
  public var body: some View {
    InnerConnect(
      updater: ConnectedStateUpdater<State, TypeOfAction>(store: storeContext.store, typeOfAction: typeOfAction),
      wrapper: self.wrapper
    )
  }
  
}

/// Binds to the `ConnectedStateUpdater` instance created in the `Connect` view to watch for updates.
private struct InnerConnect<State, TypeOfAction, Content>: View where Content : View, State : StateType, TypeOfAction : Action {
  @ObjectBinding private var updater: ConnectedStateUpdater<State, TypeOfAction>
  
  private var wrapper: ConnectedContent<Store<State>, Content>
  
  init(updater: ConnectedStateUpdater<State, TypeOfAction>, wrapper: @escaping ConnectedContent<Store<State>, Content>) {
    self.updater = updater
    self.wrapper = wrapper
  }
  
  public var body: some View {
    wrapper(updater.store.state, updater.store)
  }

}

/// The model object of the `Connect` view that updates the wrapped content when a specified action type is dispatched.
private class ConnectedStateUpdater<State, TypeOfAction> : BindableObject where State : StateType, TypeOfAction : Action {
  var didChange = PassthroughSubject<Void, Never>()
  
  let store: Store<State>
  
  private var cancel: AnyCancellable
  
  init(store: Store<State>, typeOfAction: TypeOfAction.Type) {
    self.store = store
    self.cancel = store.didChangeWithAction.filter { $0 is TypeOfAction }.map { _ in () }.subscribe(didChange)
  }
}
