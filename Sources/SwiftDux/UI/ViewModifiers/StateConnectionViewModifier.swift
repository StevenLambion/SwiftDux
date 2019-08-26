import SwiftUI

/// Indicates a connectable view should not update when the state changes. The view will not subscribe to the store, and instead update
/// only when it dispatches an action.
public struct NoUpdateAction : Action {}

/// A view modifier that injects a store into the environment.
internal struct StateConnectionViewModifier<Superstate, State> : ViewModifier {
  
  @EnvironmentObject private var superstateConnection: StateConnection<Superstate>
  @Environment(\.storeUpdated) private var storeUpdated
  @Environment(\.actionDispatcher) private var actionDispatcher
  
  private var filter: (Action)->Bool
  private var mapState: (Superstate)->State?

  internal init(filter: @escaping (Action)->Bool, mapState: @escaping (Superstate) -> State?) {
    self.filter = filter
    self.mapState = mapState
  }

  public func body(content: Content) -> some View {
    let dispatchConnection = DispatchConnection(actionDispatcher: actionDispatcher)
    let stateConnection = createStateConnection(dispatchConnection)
    return StateConnectionViewGuard(
      stateConnection: stateConnection,
      content: content
        .environment(\.actionDispatcher, dispatchConnection)
        .environmentObject(stateConnection)
    )
  }
  
  private func createStateConnection(_ dispatchConnection: DispatchConnection) -> StateConnection<State> {
    let hasUpdate = !filter(NoUpdateAction())
    let superGetState = superstateConnection.getState
    let stateConnection = StateConnection<State>(
      getState: { [mapState] in
        guard let superstate: Superstate = superGetState() else { return nil }
        return mapState(superstate)
      },
      changePublisher: hasUpdate
        ? storeUpdated.filter(filter).map { _ in }.eraseToAnyPublisher()
        : dispatchConnection.didDispatchActionPublisher.eraseToAnyPublisher()
    )
    return stateConnection
  }

}

/// View that renders the UI of a state connection only when state isn't nil.
internal struct StateConnectionViewGuard<State, Content> : View where Content : View {
  
  @ObservedObject var stateConnection: StateConnection<State>
  var content: Content
  
  var body: some View {
    if stateConnection.latestState != nil {
      return AnyView(content)
    }
    return AnyView(EmptyView())
  }
  
}


extension View {
  
  /// Connect the application state to the UI.
  ///
  /// The returned mapped state is provided to the environment and accessible through the `MappedState` property wrapper.
  ///
  /// - Parameters
  ///   - updateWhen: Update the state when the closure returns true. If not provided, it will only update when dispatching an action.
  ///   - mapState: Maps a superstate to a substate.
  @available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
  public func connect<Superstate, State>(
    updateWhen filter: @escaping (Action)->Bool = { $0 is NoUpdateAction },
    mapState: @escaping (Superstate) -> State?
  ) -> some View {
    self.modifier(StateConnectionViewModifier(filter: filter, mapState: mapState))
  }
  
}
