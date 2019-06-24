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

  var exceptWhen: ((KindOfAction)->Bool)?
  var mapper: (Superstate) -> Substate?

  public init(kindOfAction: KindOfAction.Type, exceptWhen: ((KindOfAction)->Bool)?, _ mapper: @escaping (Superstate) -> Substate?) {
    self.exceptWhen = exceptWhen
    self.mapper = mapper
  }

  public func body(content: Content) -> some View {
    var filter: (Action)->Bool
    if let exceptWhen = exceptWhen {
      filter = {
        if let action = $0 as? KindOfAction {
          return !exceptWhen(action)
        }
        return false
      }
    } else {
      filter = { $0 is KindOfAction }
    }
    return content
      .environmentObject(StateContext<Substate>(
        didChangeWithActionPublisher: stateContext.didChangeWithAction,
        didChangePublisher: stateContext.didChangeWithAction
          .filter(filter)
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
  ///   - updateOn: The dispatched action that will trigger updates.
  ///   - exceptWhen: An optional closure to filter out specific actions. This can be useful for actions that don't change the state such as ones that route child actions.
  ///   - mapper: Returns the substate from the superstate.
  /// - Returns: A view modifier.
  public func mapState<KindOfAction, Superstate, Substate>(
    updateOn kindOfAction: KindOfAction.Type,
    exceptWhen: ((KindOfAction)->Bool)? = nil,
    _ mapper: @escaping (Superstate) -> Substate?
    ) -> Self.Modified<StateMapper<KindOfAction, Superstate, Substate>> where KindOfAction : Action, Superstate : StateType, Substate : StateType {
    return self.modifier(StateMapper(kindOfAction: kindOfAction, exceptWhen: exceptWhen, mapper))
  }
}
