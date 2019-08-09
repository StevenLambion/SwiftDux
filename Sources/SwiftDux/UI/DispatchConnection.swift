import Foundation
import Combine

final class DispatchConnection : ObservableObject, Identifiable {
  var objectWillChange = ObservableObjectPublisher()
  
  var actionDispatcher: ActionDispatcher
  
  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher
  }
  
  func send(action: Action) {
    objectWillChange.send()
    actionDispatcher.send(action)
  }
}
