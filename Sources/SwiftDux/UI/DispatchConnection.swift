import Foundation
import Combine

internal final class DispatchConnection : ObservableObject, Identifiable {
  var objectWillChange = ObservableObjectPublisher()
  
  var actionDispatcher: ActionDispatcher
  
  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher
  }
  
  func send(action: Action) {
    self.objectWillChange.send()
    actionDispatcher.send(action)
  }
}
