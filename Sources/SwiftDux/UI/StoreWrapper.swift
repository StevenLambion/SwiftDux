import Combine
import SwiftUI

internal final class StoreWrapper<State>: ObservableObject {
  let store: StoreProxy<State>

  init(store: StoreProxy<State>) {
    self.store = store
  }
}
