import SwiftUI
import Combine

public class StoreContext<State> : BindableObject where State : StateType {
  public var didChange = Publishers.Empty<Void, Never>()
  public var store: Store<State>
  
  init(store: Store<State>) {
    self.store = store
  }
}
