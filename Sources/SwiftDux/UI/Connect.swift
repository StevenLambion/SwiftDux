import SwiftUI
import Combine

public typealias ConnectContentWrapper<Dispatcher, S, Content> = (S, Dispatcher) -> Content
  where Dispatcher: ActionPlanDispatcher, Content: View, S == Dispatcher.State

/// Connects the application state to a view.
///
/// The connection maps the application's state to values that can be passed into a view. It then updates the view when
/// a relevant action type is performed.
///
/// struct TodoListContainer: View {
///   ....
/// }
///
/// extension TodoListContainer {
///
///   static func connected() -> some View {
///     Store<AppState>.connect(updateFor: TodoAction.self) { todos, dispatcher in
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
public struct Connect<S, A, Content>: View where Content: View, S: StateType, A: Action {
  @EnvironmentObject private var store: Store<S>
  private var actionType: A.Type
  private var wrapper: ConnectContentWrapper<Store<S>, S, Content>
  
  public init(updateFor actionType: A.Type, wrapper: @escaping ConnectContentWrapper<Store<S>, S, Content>) {
    self.actionType = actionType
    self.wrapper = wrapper
  }
  
  public var body: some View {
    InnerConnect(store: store, actionType: self.actionType, wrapper: self.wrapper)
  }
  
}

extension Store {
 
  public static func connect<A, Content>(
    updateFor actionType: A.Type,
    wrapper: @escaping ConnectContentWrapper<Store<State>, State, Content>
  ) -> some View where A: Action, Content: View {
    return Connect<State, A, Content>(updateFor: actionType, wrapper: wrapper)
  }
  
}

/// The Connect view is used to simply get the store object and pass it to the the InnerConnect view. This view
/// keeps track of dispatched actions to automatically update its contents when necessary.
private struct InnerConnect<StoreState, A, Content>: View where Content: View, StoreState: StateType, A: Action {
  @ObjectBinding private var updater: StoreActionUpdater<StoreState, A>
  
  private var store: Store<StoreState>
  private var wrapper: ConnectContentWrapper<Store<StoreState>, StoreState, Content>
  
  init(store: Store<StoreState>, actionType: A.Type, wrapper: @escaping ConnectContentWrapper<Store<StoreState>, StoreState, Content>) {
    self.store = store
    self.updater = StoreActionUpdater<StoreState, A>()
    self.wrapper = wrapper
  }
  
  public var body: some View {
    wrapper(store.state, store)
      .onAppear { self.updater.beginSubscription(store: self.store, action: A.self) }
      .onDisappear { self.updater.cancelSubscription() }
  }

}

private class StoreActionUpdater<S, A>: BindableObject where S: StateType, A: Action {
  var didChange = PassthroughSubject<Void, Never>()
  var canceller: AnyCancellable?
  
  func beginSubscription(store: Store<S>, action: A.Type) {
    guard canceller == nil else { return }
    self.canceller = store.didChangeWithAction.filter { $0 is A }.map { _ in () }.subscribe(didChange)
  }
  
  func cancelSubscription() {
    self.canceller?.cancel()
    self.canceller = nil
  }
}
