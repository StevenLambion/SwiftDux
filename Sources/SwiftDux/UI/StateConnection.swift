import Combine
import Foundation
import SwiftUI

/// Obserable container of mapped state used by a view.
///
/// It uses a "change publisher" to notify it to retrieve a new version of the state object. This publisher
/// typically fires from the store after the state has been modified, or directly from an action being dispatched.
internal final class StateConnection<State>: ObservableObject, Identifiable where State: Equatable {
  @Published var state: State?

  private var getState: () -> State? = { nil }
  private var changePublisher: AnyPublisher<Action, Never>
  private var cancellable: Cancellable? = nil

  init(getState: @escaping () -> State?, changePublisher: AnyPublisher<Action, Never>, emitChanges: Bool = true) {
    self.getState = getState
    self.changePublisher = changePublisher
    self.state = getState()

    if emitChanges {
      self.cancellable = changePublisher.compactMap { _ in getState() }.sink { [weak self] state in
        guard state != self?.state else { return }
        self?.state = state
      }
    }
  }

  func map<Substate>(
    state mapState: @escaping (State, StateBinder) -> Substate?,
    changePublisher: AnyPublisher<Action, Never>? = nil,
    binder: StateBinder
  ) -> StateConnection<Substate> {
    let getSubstate: () -> Substate? = { [getState] in
      guard let superstate = getState() else { return nil }
      return mapState(superstate, binder)
    }
    return StateConnection<Substate>(
      getState: getSubstate,
      changePublisher: changePublisher ?? self.changePublisher
    )
  }
}

extension Binding: Equatable where Value: Equatable {

  public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }

}
