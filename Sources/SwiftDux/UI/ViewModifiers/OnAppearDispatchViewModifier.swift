import Combine
import SwiftUI

internal struct OnAppearDispatchViewModifier: ViewModifier {
  @MappedDispatch() private var dispatch

  var action: Action
  var cancelOnDisappear: Bool

  @State private var cancellable: Cancellable? = nil

  internal init(action: Action, cancelOnDisappear: Bool) {
    self.action = action
    self.cancelOnDisappear = cancelOnDisappear
  }

  public func body(content: Content) -> some View {
    content
      .onAppear { [action, dispatch] in
        guard self.cancellable == nil else { return }
        if let actionPlan = action as? CancellableAction {
          self.cancellable = actionPlan.sendAsCancellable(dispatch)
        } else {
          dispatch(action)
        }
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

  /// Sends the provided action when the view appears. If an action plan is provided, it will send it as a cancellable plan.
  /// This let's the view modifier automatically clean up the publisher if it's connected to an external service or API when the view
  /// disappears.
  ///
  /// ```
  /// @MappedState var items: [TodoItem]
  ///
  /// var body: some View {
  ///   Group {
  ///     TodoList(items: items)
  ///   }
  ///   .onAppear(dispatch: ActionPlans.queryTodoItems)
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - action: An action to dispatch every time the view appears.
  ///   - cancelOnDisappear: It will cancel any subscription from the action when the view disappears. If false, it keeps
  ///     the subscription alive and reppearances of the view will not re-call the action.
  /// - Returns: The modified view.
  @available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
  public func onAppear(dispatch action: Action, cancelOnDisappear: Bool = true) -> some View {
    modifier(OnAppearDispatchViewModifier(action: action, cancelOnDisappear: cancelOnDisappear))
  }

}
