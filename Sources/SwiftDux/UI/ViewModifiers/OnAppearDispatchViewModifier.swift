import Combine
import SwiftUI

public struct OnAppearDispatchActionViewModifier: ViewModifier {
  @MappedDispatch() private var dispatch

  var action: Action

  @State private var cancellable: Cancellable? = nil

  @usableFromInline internal init(action: Action) {
    self.action = action
  }

  public func body(content: Content) -> some View {
    content.onAppear { [action, dispatch] in dispatch(action) }
  }
}

public struct OnAppearDispatchActionPlanViewModifier<T>: ViewModifier {
  @MappedDispatch() private var dispatch

  var actionPlan: ActionPlan<T>
  var cancelOnDisappear: Bool

  @State private var cancellable: Cancellable? = nil

  @usableFromInline internal init(actionPlan: ActionPlan<T>, cancelOnDisappear: Bool) {
    self.actionPlan = actionPlan
    self.cancelOnDisappear = cancelOnDisappear
  }

  public func body(content: Content) -> some View {
    content
      .onAppear { [actionPlan, dispatch] in
        guard self.cancellable == nil else { return }
        self.cancellable = actionPlan.sendAsCancellable(dispatch)
      }
      .onDisappear { [cancelOnDisappear] in
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
    modifier(OnAppearDispatchActionViewModifier(action: action))
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
  ///   - actionPlan: An action to dispatch every time the view appears.
  ///   - cancelOnDisappear: It will cancel any subscription from the action when the view disappears. If false, it keeps
  ///     the subscription alive and reppearances of the view will not re-call the action.
  /// - Returns: The modified view.
  @inlinable public func onAppear<T>(dispatch actionPlan: ActionPlan<T>, cancelOnDisappear: Bool = true) -> some View {
    modifier(OnAppearDispatchActionPlanViewModifier(actionPlan: actionPlan, cancelOnDisappear: cancelOnDisappear))
  }
}
