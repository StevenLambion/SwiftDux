import SwiftUI
import Combine

/// A view modifier that injects a store into the environment.
public struct StoreProvider<State> : ViewModifier where State : StateType {
  
  private var storeContext: StoreContext<State>
  private var dispatcherContext: DispatcherContext

  public init(store: Store<State>) {
    self.storeContext = StoreContext(store: store)
    self.dispatcherContext = DispatcherContext(dispatcher: store.proxy())
  }

  public func body(content: Content) -> some View {
    content
      .environmentObject(storeContext)
      .environmentObject(dispatcherContext)
  }

}
