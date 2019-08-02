import Foundation
import Combine

final internal class StateConnection<State> : ObservableObject, Identifiable {
  var getState: (() -> State?)
  var cancellable: AnyCancellable? = nil
  
  /// Required to cause a SwiftUI update. Sending directly to the objectWIllChange publisher has no effect
  /// without some kind of state change.
  @Published var causeRefresh: Action = EmptyAction()
  
  init(getState: @escaping (() -> State?), willChangePublisher: AnyPublisher<Action, Never>?) {
    self.getState = getState
    self.cancellable = willChangePublisher?.sink { [weak self] _ in
      self?.causeRefresh = EmptyAction()
    }
  }
}
