import SwiftUI
import Combine

/// Internal view used by the Connector to retrieve the store from the environment.
internal struct ConnectorView<State, Content> : View where State : StateType, Content : View {
  @MappedState private var state: State
  @Environment(\.actionDispatcher) private var actionDispatcher
  
  private var content: (State, ActionDispatcher) -> Content?
  
  init(@ViewBuilder content: @escaping (State, ActionDispatcher) -> Content) {
    self.content = content
  }
  
  var body: some View {
    guard let contentView = content(state, actionDispatcher) else {
      return AnyView(EmptyView())
    }
    return AnyView(contentView)
  }
}
