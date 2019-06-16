import SwiftUI
import Combine

/// A closure containing the content that will be connected to the application's state and an action dispatcher.
public typealias ActionConnectContent<Dispatcher, Content> = (Dispatcher.State, Dispatcher) -> Content
  where Dispatcher : ActionPlanDispatcher, Content : View

extension Store {
  
  /// Connects the application state to a view.
  ///
  /// The connection provides the state of the application to map them to a views properties. It then updates the view when
  /// a relevant action type is performed. The store must be injected into the environment before this function can be used.
  /// To do this, use the `provideStore(_:)` modifier off of a View instance.
  ///```
  ///
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
    wrapper: @escaping ActionConnectContent<StoreActionDispatcher<State>, Content>
  ) -> some View where TypeOfAction : Action, Content : View {
    return ActionConnect<State, TypeOfAction, Content>(updateOn: typeOfAction, wrapper: wrapper)
  }
  
}

/// Retrieves the current store and dispatcher from the environment and creates a `ConnectedStateUpdater` instance
/// to update the wrapped content when the specified action type is dispatched.
private struct ActionConnect<State, TypeOfAction, Content> : View where Content : View, State : StateType, TypeOfAction : Action {
  @EnvironmentObject private var storeContext: StoreContext<State>
  
  private var typeOfAction: TypeOfAction.Type
  private var wrapper: ActionConnectContent<StoreActionDispatcher<State>, Content>
  
  public init(updateOn typeOfAction: TypeOfAction.Type, wrapper: @escaping ActionConnectContent<StoreActionDispatcher<State>, Content>) {
    self.typeOfAction = typeOfAction
    self.wrapper = wrapper
  }
  
  public var body: some View {
    ActionInnerConnect(
      updater: ActionConnectedStateUpdater<State, TypeOfAction>(
        store: storeContext.store,
        dispatcher: storeContext.dispatcher,
        typeOfAction: typeOfAction
      ),
      wrapper: self.wrapper
    )
  }
  
}

/// Binds to the `ConnectedStateUpdater` instance created in the `Connect` view to watch for updates.
private struct ActionInnerConnect<State, TypeOfAction, Content>: View where Content : View, State : StateType, TypeOfAction : Action {
  @ObjectBinding private var updater: ActionConnectedStateUpdater<State, TypeOfAction>
  
  private var wrapper: ActionConnectContent<StoreActionDispatcher<State>, Content>
  
  init(
    updater: ActionConnectedStateUpdater<State, TypeOfAction>,
    wrapper: @escaping ActionConnectContent<StoreActionDispatcher<State>, Content>
  ) {
    self.updater = updater
    self.wrapper = wrapper
  }
  
  public var body: some View {
    wrapper(updater.store.state, updater.dispatcher)
  }

}

/// The model object of the `Connect` view that updates the wrapped content when a specified action type is dispatched.
private class ActionConnectedStateUpdater<State, TypeOfAction> : BindableObject where State : StateType, TypeOfAction : Action {
  var didChange = PassthroughSubject<Void, Never>()
  
  let store: Store<State>
  let dispatcher: StoreActionDispatcher<State>
  
  private var cancel: AnyCancellable
  
  init(store: Store<State>, dispatcher: StoreActionDispatcher<State>, typeOfAction: TypeOfAction.Type) {
    self.store = store
    self.dispatcher = dispatcher
    self.cancel = store.on(typeOfAction: typeOfAction).subscribe(didChange)
  }
  
}
