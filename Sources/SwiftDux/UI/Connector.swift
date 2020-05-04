import Combine
import SwiftUI

/// Indicates a connectable view should not update when the state changes. The view will not subscribe to the store, and instead update
/// only when it dispatches an action.
internal final class NoUpdateAction: Action {
  var unused: Bool = false
}

fileprivate let noUpdateAction = NoUpdateAction()

internal struct Connector<Content, Superstate, Props>: View where Superstate: Equatable, Props: Equatable, Content: View {
  @EnvironmentObject private var storeWrapper: StoreWrapper<Superstate>
  @Environment(\.actionDispatcher) private var actionDispatcher

  private var content: (Props) -> Content
  private var filter: ((Action) -> Bool)?
  private var mapProps: (Superstate, ActionBinder) -> Props?

  private var store: Store<Superstate> {
    storeWrapper.store
  }

  @usableFromInline internal init(
    content: @escaping (Props) -> Content,
    filter: ((Action) -> Bool)?,
    mapProps: @escaping (Superstate, ActionBinder) -> Props?
  ) {
    self.content = content
    self.filter = filter
    self.mapProps = mapProps
  }

  var body: some View {
    ConnectorInner(content: content, initialProps: getProps(), propsPublisher: createPropsPublisher())
  }

  private func createPropsPublisher() -> AnyPublisher<Props, Never> {
    createFilteredPublisher().compactMap { [store] _ in
      self.mapProps(store.state, ActionBinder(actionDispatcher: self.actionDispatcher))
    }
    .removeDuplicates()
    .eraseToAnyPublisher()
  }

  private func createFilteredPublisher() -> AnyPublisher<Action, Never> {
    guard let filter = filter, hasUpdateFilter() else {
      return store.didChange
    }
    return store.didChange.filter(filter).eraseToAnyPublisher()
  }

  private func getProps() -> Props? {
    mapProps(store.state, ActionBinder(actionDispatcher: self.actionDispatcher))
  }

  private func hasUpdateFilter() -> Bool {
    _ = filter?(noUpdateAction)
    return !noUpdateAction.unused
  }
}

internal struct ConnectorInner<Content, Props>: View where Props: Equatable, Content: View {
  private var content: (Props) -> Content
  private var propsPublisher: AnyPublisher<Props, Never>

  @State private var props: Props?

  internal init(content: @escaping (Props) -> Content, initialProps: Props?, propsPublisher: AnyPublisher<Props, Never>) {
    self.content = content
    self.propsPublisher = propsPublisher
    self._props = State(initialValue: initialProps)
  }

  var body: some View {
    return props.map { [content] in
      content($0).onReceive(propsPublisher) { self.props = $0 }
    }
  }
}
