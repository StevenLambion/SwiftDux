import SwiftUI

/// A view modifier that injects a store into the environment.
internal struct StateConnectionViewModifier<Superstate, State> : ViewModifier {
  
  @EnvironmentObject private var superstateConnection: StateConnection<Superstate>
  @Environment(\.storeUpdated) private var storeUpdated
  
  private var filter: (Action)->Bool
  private var mapState: (Superstate)->State?

  internal init(filter: @escaping (Action)->Bool, mapState: @escaping (Superstate) -> State?) {
    self.filter = filter
    self.mapState = mapState
  }

  public func body(content: Content) -> some View {
    content.environmentObject(StateConnection<State>(
      getState: { [weak superstateConnection, mapState] in
        guard let superstate: Superstate = superstateConnection?.getState() else { return nil }
        return mapState(superstate)
      },
      willChangePublisher: storeUpdated.filter(filter).eraseToAnyPublisher())
    )
  }

}

extension View {
  
  /// Connect the application state to the UI.
  ///
  /// The returned mapped state is provided to the environment and accessible through the `MappedState` property wrapper.
  ///
  /// - Parameters
  ///   - updateWhen: Update the state when the closure returns true
  ///   - mapState: Maps a superstate to a substate.
  @available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
  public func connect<Superstate, State>(
    updateWhen filter: @escaping (Action)->Bool,
    mapState: @escaping (Superstate) -> State?
  ) -> some View {
    self.modifier(StateConnectionViewModifier(filter: filter, mapState: mapState))
  }
  
}
