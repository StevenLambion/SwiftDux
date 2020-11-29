import Combine
import Dispatch
import SwiftUI

public struct OnAppearDispatchActionViewModifier: ViewModifier {
  @Environment(\.actionDispatcher) private var dispatch
  @State private var cancellable: Cancellable? = nil
  private var action: Action

  @usableFromInline internal init(action: Action) {
    self.action = action
  }

  public func body(content: Content) -> some View {
    content.onAppear { dispatch(action) }
  }
}

public struct OnAppearDispatchActionPlanViewModifier: ViewModifier {
  @Environment(\.actionDispatcher) private var dispatch

  private var action: RunnableAction
  private var cancelOnDisappear: Bool

  @State private var cancellable: Cancellable? = nil

  @usableFromInline internal init(action: RunnableAction, cancelOnDisappear: Bool) {
    self.action = action
    self.cancelOnDisappear = cancelOnDisappear
  }

  public func body(content: Content) -> some View {
    content
      .onAppear {
        guard cancellable == nil else { return }
        self.cancellable = dispatch.sendAsCancellable(action)
      }
      .onDisappear {
        if cancelOnDisappear {
          self.cancellable?.cancel()
          self.cancellable = nil
        }
      }
  }
}

extension View {

  /// Sends the provided action when the view appears.
  ///
  /// - Parameter action: An action to dispatch every time the view appears.
  /// - Returns: The modified view.
  @inlinable public func onAppear(dispatch action: Action) -> some View {
    Group {
      if let action = action as? RunnableAction {
        modifier(OnAppearDispatchActionPlanViewModifier(action: action, cancelOnDisappear: true))
      } else {
        modifier(OnAppearDispatchActionViewModifier(action: action))
      }
    }
  }

  /// Sends the provided action plan when the view appears.
  ///
  /// In the follow example an ActionPlan is created that automatically updates a list of todos when the filter property of
  /// the TodoList state changes. All the view needs to do is dispatch the action when it appears.
  /// ```
  /// // In the TodoListAction file:
  ///
  /// enum TodoListAction: Action {
  ///   case setTodos([TodoItem])
  ///   case setFilterBy(String)
  /// }
  ///
  /// extension TodoListAction {
  ///
  ///   static func queryTodos(from services: Services) -> Action {
  ///     ActionPlan<AppState> { store in
  ///       store.didChange
  ///         .filter { $0 is TodoListAction }
  ///         .map { _ in store.state?.todoList.filterBy ?? "" }
  ///         .removeDuplicates()
  ///         .flatMap { filter in
  ///           services
  ///             .queryTodos(filter: filter)
  ///             .catch { _ in Just<[TodoItem]>([]) }
  ///             .map { todos -> Action in TodoListAction.setTodos(todos) }
  ///         }
  ///     }
  ///   }
  /// }
  ///
  /// // In a SwiftUI View:
  ///
  /// @Environment(\.services) private var services
  /// @MappedState private var todos: [TodoItem]
  ///
  /// var body: some View {
  ///   Group {
  ///     renderTodos(todos: todos)
  ///   }
  ///   .onAppear(dispatch: TodoListAction.queryTodos(from: services))
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - action: An action to dispatch every time the view appears.
  ///   - cancelOnDisappear: It will cancel any subscription from the action when the view disappears. If false, it keeps
  ///     the subscription alive and reppearances of the view will not re-call the action.
  /// - Returns: The modified view.
  @inlinable public func onAppear<T>(dispatch action: RunnableAction, cancelOnDisappear: Bool) -> some View {
    modifier(OnAppearDispatchActionPlanViewModifier(action: action, cancelOnDisappear: cancelOnDisappear))
  }
}
