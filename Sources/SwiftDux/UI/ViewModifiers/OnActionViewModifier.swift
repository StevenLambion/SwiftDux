import Combine
import SwiftUI

public struct OnActionViewModifier: ViewModifier {
  @Environment(\.actionDispatcher) private var actionDispatcher
  private var perform: ActionModifier? = nil

  @usableFromInline internal init(perform: ActionModifier? = nil) {
    self.perform = perform
  }

  public func body(content: Content) -> some View {
    var nextActionDispatcher = actionDispatcher
    if let perform = perform {
      nextActionDispatcher = actionDispatcher.proxy(modifyAction: perform)
    }
    return content.environment(\.actionDispatcher, nextActionDispatcher)
  }
}

extension View {

  /// Fires when a child view dispatches an action.
  ///
  /// - Parameter perform: Calls the closure when an action is dispatched. An optional new action can be returned to change the action.
  /// - Returns: The modified view.
  @inlinable public func onAction(perform: @escaping ActionModifier) -> some View {
    modifier(OnActionViewModifier(perform: perform))
  }
}
