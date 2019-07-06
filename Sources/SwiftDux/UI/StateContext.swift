import Foundation
import Combine
import SwiftUI

internal class StateContext<State> : BindableObject where State : StateType {
  var didChange = PassthroughSubject<Action, Never>()

  var filter: (Action) -> Bool
  
  var state: State? {
    store?.state
  }
  
  var cancellable: AnyCancellable?
  
  var store: Store<State>? = nil {
    didSet {
      guard oldValue !== store else { return }
      guard let store = store else { return }
      let didChangePublisher = store.didChange.filter(filter)
      cancellable = didChangePublisher.subscribe(didChange)
    }
  }

  init(filter: @escaping (Action) -> Bool) {
    self.filter = filter
  }
}
