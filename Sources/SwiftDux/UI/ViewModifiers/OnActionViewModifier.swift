import Combine
import SwiftUI

internal struct OnActionViewModifier: ViewModifier {
  @Environment(\.actionDispatcher) private var actionDispatcher

  private var perform: ActionModifier? = nil

  internal init(perform: ActionModifier? = nil) {
    self.perform = perform
  }

  public func body(content: Content) -> some View {
    let proxy = actionDispatcher.proxy(modifyAction: perform, sentAction: nil)
    return content.environment(\.actionDispatcher, proxy)
  }

}

extension View {

  /// Fires when a child view dispatches an action.
  ///
  /// - Parameter perform: Calls the closure when an action is dispatched. An optional new action can be returned to change the action.
  /// - Returns: The modified view.
  @available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
  public func onAction(perform: @escaping ActionModifier) -> some View {
    modifier(OnActionViewModifier(perform: perform))
  }

}
