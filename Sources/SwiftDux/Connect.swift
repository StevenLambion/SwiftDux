import SwiftUI
import Combine

public struct Connect<S, A, T, Content>: View where Content: View, S: StateType, A: Action {
  @EnvironmentObject var store: Store<S>
  @State var state: T? = nil
  public var mapState: (S) -> T?
  public var content: (T, ActionDispatcher) -> Content
  public var body: some View {
    AnyView(renderContent())
      .onReceive(store.map(for: A.self, mapState: mapState)) { self.state = $0 }
  }
  
  public init(with mapState: @escaping (S) -> T?, updateOn action: A.Type, content: @escaping (T, ActionDispatcher) -> Content) {
    self.mapState = mapState
    self.content = content
  }
  
  func renderContent() -> AnyView {
    if let state =  state ?? mapState(store.state) {
      return AnyView(content(state, store))
    }
    return AnyView(EmptyView())
  }

}
