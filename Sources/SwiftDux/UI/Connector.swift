import Combine
import SwiftUI

public struct Connector<Content, State, Props>: View where Props: Equatable, Content: View {
  @Environment(\.store) private var anyStore
  @Dispatch private var dispatch

  private var mapState: (State, ActionBinder) -> Props?
  private var content: (Props) -> Content
  @SwiftUI.State private var props: Props?

  private var store: StoreProxy<State>? {
    if anyStore is NoopAnyStore {
      return nil
    } else if let store = anyStore.unwrap(as: State.self) {
      return store
    }
    fatalError("Tried mapping the state to a view, but the Store<_> doesn't conform to '\(State.self)'")
  }

  public init(
    mapState: @escaping (State, ActionBinder) -> Props?,
    @ViewBuilder content: @escaping (Props) -> Content
  ) {
    self.content = content
    self.mapState = mapState
  }

  public var body: some View {
    store.map { store in
      Group {
        props.map { content($0) }
      }.onReceive(store.publish(mapState)) { self.props = $0 }
    }
  }

  private func mapState(state: State) -> Props? {
    mapState(state, ActionBinder(actionDispatcher: dispatch))
  }
}
