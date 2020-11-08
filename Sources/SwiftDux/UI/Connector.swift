import Combine
import SwiftUI

public struct Connector<Content, Superstate, Props>: View where Props: Equatable, Content: View {
  @Environment(\.store) private var anyStore
  @Environment(\.actionDispatcher) private var actionDispatcher

  private var content: (Props) -> Content
  private var mapProps: (Superstate, ActionBinder) -> Props?

  private var store: StoreProxy<Superstate>? {
    if anyStore is NoopAnyStore {
      return nil
    } else if let store = anyStore.unwrap(as: Superstate.self) {
      return store
    }
    fatalError("Tried mapping the state to a view, but the Store<_> doesn't conform to '\(Superstate.self)'")
  }

  public init(
    content: @escaping (Props) -> Content,
    mapProps: @escaping (Superstate, ActionBinder) -> Props?
  ) {
    self.content = content
    self.mapProps = mapProps
  }

  public var body: some View {
    store.map { store in
      ConnectorInner(
        content: content,
        initialProps: getProps(),
        propsPublisher: store.didChange
          .compactMap { _ in getProps() }
          .removeDuplicates()
      )
    }
  }

  private func getProps() -> Props? {
    guard let store = store else { return nil }
    return mapProps(store.state, ActionBinder(actionDispatcher: self.actionDispatcher))
  }
}

internal struct ConnectorInner<Props, PropsPublisher, Content>: View
where Props: Equatable, PropsPublisher: Publisher, PropsPublisher.Output == Props, PropsPublisher.Failure == Never, Content: View {
  private var content: (Props) -> Content
  private var propsPublisher: PropsPublisher
  @State private var props: Props?

  internal init(content: @escaping (Props) -> Content, initialProps: Props?, propsPublisher: PropsPublisher) {
    self.content = content
    self.propsPublisher = propsPublisher
    self._props = State(initialValue: initialProps)
  }

  var body: some View {
    return props.map { content($0).onReceive(propsPublisher) { self.props = $0 } }
  }
}
