import Foundation
import Combine

internal final class StateConnection<State> : ObservableObject, Identifiable {
  
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
