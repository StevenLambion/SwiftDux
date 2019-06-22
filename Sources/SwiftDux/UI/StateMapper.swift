import Foundation
import Combine
import SwiftUI

internal class StateContext<State> : BindableObject where State : StateType {
  public var didChange: AnyPublisher<Void, Never>
  public var didChangeWithAction: AnyPublisher<Action, Never>

  public var getState: () -> State?

  public var state: State? {
    getState()
  }

  public init(didChangeWithActionPublisher: AnyPublisher<Action, Never>, didChangePublisher: AnyPublisher<Void, Never>,  state getState: @escaping () -> State?) {
    self.didChangeWithAction = didChangeWithActionPublisher
    self.getState = getState
    self.didChange = didChangePublisher
  }
}

/// Maps a superstate to a substate. It updates views using a passed in change publisher.
///
/// This should not be used diectly, but through `View.mapState(updateOn:_:)`.
public struct StateMapper<KindOfAction, Superstate, Substate>: ViewModifier where KindOfAction : Action, Superstate : StateType, Substate : StateType {
  @EnvironmentObject var stateContext: StateContext<Superstate>

  var mapper: (Superstate) -> Substate?

  public init(kindOfAction: KindOfAction.Type, _ mapper: @escaping (Superstate) -> Substate?) {
    self.mapper = mapper
  }

  public func body(content: Content) -> some View {
    return content
      .environmentObject(StateContext<Substate>(
        didChangeWithActionPublisher: stateContext.didChangeWithAction,
        didChangePublisher: stateContext.didChangeWithAction
          .filter { $0 is KindOfAction }
          .map { _ in () }
          .eraseToAnyPublisher(),
        state: getSubstate)
    )
  }
  
  func getSubstate() -> Substate? {
    if let superstate = self.stateContext.state {
      return self.mapper(superstate)
    }
    return nil
  }

}

extension View {

  /// Maps a superstate to a substate, and updates when a particular action is dispatched.
  /// - Parameters
  ///   - typeOfState: The superstate to map from.
  ///   - kindofAction: The dispatchewd action that will trigger updates.
  ///   - mapper: Returns the substate from the superstate.
  /// - Returns: A view modifier.
  public func mapState<KindOfAction, Superstate, Substate>(
    updateOn kindOfAction: KindOfAction.Type,
    _ mapper: @escaping (Superstate) -> Substate?
    ) -> Self.Modified<StateMapper<KindOfAction, Superstate, Substate>> where KindOfAction : Action, Superstate : StateType, Substate : StateType {
    return self.modifier(StateMapper(kindOfAction: kindOfAction, mapper))
  }
}
