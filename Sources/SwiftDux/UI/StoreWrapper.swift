import Combine
import SwiftUI

internal final class StoreWrapper<State>: ObservableObject {
  let store: Store<State>

  init(store: Store<State>) {
    self.store = store
  }
}
