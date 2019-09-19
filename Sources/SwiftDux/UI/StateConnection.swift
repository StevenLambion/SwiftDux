import Foundation
import Combine

/// Obserable container of mapped state used by a view.
///
/// It uses a "change publisher" to notify it to retrieve a new version of the state object. This publisher
/// typically fires from the store after the state has been modified, or directly from an action being dispatched.
internal final class StateConnection<State>: ObservableObject, Identifiable {

  @Published var latestState: State?

  var getState: () -> State?

  private var cancellable: AnyCancellable? = nil

  init(getState: @escaping () -> State?, changePublisher: AnyPublisher<Void, Never>) {
    self.getState = getState
    self.latestState = getState()
    self.cancellable = changePublisher.sink { [weak self] in
      guard let self = self else { return }
      self.latestState = getState()
    }
  }
}
