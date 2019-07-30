import Foundation
import Combine

final internal class StateConnection<State> : ObservableObject, Identifiable {
  var getState: (() -> State?)
  var cancellable: AnyCancellable? = nil
  
  @Published var lastAction: Action = EmptyAction()
  
  init(getState: @escaping (() -> State?), willChangePublisher: AnyPublisher<Action, Never>) {
    self.getState = getState
    self.cancellable = willChangePublisher.assign(to: \.lastAction, on: self)
  }
}
