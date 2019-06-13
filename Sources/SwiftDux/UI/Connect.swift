import SwiftUI
import Combine

public typealias ConnectContent<Dispatcher, State, T, Content> = (T, Dispatcher) -> Content
  where Dispatcher: ActionPlanDispatcher, Content: View, State == Dispatcher.State

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
///     Connect({ $0.todos }, updateFor: TodoAction.self) { todos, dispatcher in
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
public struct Connect<StoreState, T, A, Content>: View where Content: View, StoreState: StateType, A: Action {
  @EnvironmentObject private var store: Store<StoreState>
  @State private var state: T? = nil
  
  private var mapState: (StoreState) -> T?
  private var content: ConnectContent<Store<StoreState>, StoreState, T, Content>
  public var body: some View {
    AnyView(renderContent())
      .onReceive(store.on(action: A.self, mapState: mapState)) { self.state = $0 }
  }
  
  public init(
    _ mapState: @escaping (StoreState) -> T?,
    updateFor actionType: A.Type,
    content: @escaping ConnectContent<Store<StoreState>, StoreState, T, Content>
  ) {
    self.mapState = mapState
    self.content = content
  }
  
  private func renderContent() -> AnyView {
    if let state =  state ?? mapState(store.state) {
      return AnyView(content(state, store))
    }
    return AnyView(EmptyView())
  }

}
