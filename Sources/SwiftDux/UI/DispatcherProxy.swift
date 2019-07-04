import SwiftUI
import Combine

public struct DispatcherProxy: ViewModifier {
  @EnvironmentObject private var dispatcherContext: DispatcherContext
  
  private var modifyAction: ActionModifier? = nil
  
  public init(modifyAction: ActionModifier? = nil) {
    self.modifyAction = modifyAction
  }
  
  public func body(content: Content) -> some View {
    let dispatcher = dispatcherContext.dispatcher.proxy(modifyAction: modifyAction)
    return content
      .environmentObject(DispatcherContext(dispatcher: dispatcher))
  }
  
}
