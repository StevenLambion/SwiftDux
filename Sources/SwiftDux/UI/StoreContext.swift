import SwiftUI
import Combine

internal class StoreContext<State> : BindableObject where State : StateType {
  var didChange = Publishers.Empty<Void, Never>()
  var store: Store<State>
  
  init(store: Store<State>) {
    self.store = store
  }
}
