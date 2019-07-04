import SwiftUI
import Combine

/// Internal view used by the Connector to retrieve the store from the environment.
internal struct ConnectorView<State, Content> : View where State : StateType, Content : View {
  @EnvironmentObject private var storeContext: StoreContext<State>
  
  private var stateContext: StateContext<State>
  private var content: (State, ActionDispatcher) -> Content?
  
  init(stateContext: StateContext<State>, @ViewBuilder content: @escaping (State, ActionDispatcher) -> Content) {
    self.stateContext = stateContext
    self.content = content
  }
  
  var body: some View {
    stateContext.store = storeContext.store
    return ConnectorWrapper(stateContext: stateContext, content: content)
  }
}

/// A view modifier that injects a store into the environment. Use the
/// `View.provideStore(_:)`` method instead of this type directly.
internal struct ConnectorWrapper<State, Content> : View where State : StateType, Content : View {
  @EnvironmentObject private var dispatcherContext: DispatcherContext
  
  @ObjectBinding var stateContext: StateContext<State>
  var content: (State, ActionDispatcher) -> Content?
  
  public var body: some View {
    guard let state = stateContext.state, let contentView = content(state, dispatcherContext.dispatcher) else {
      return AnyView(EmptyView())
    }
    return AnyView(contentView)
  }
}
