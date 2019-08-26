import Foundation
import Combine

internal final class DispatchConnection : ActionDispatcher {
  
  var didDispatchActionPublisher = ObservableObjectPublisher()
  
  var actionDispatcher: ActionDispatcher
  
  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher
  }
  
  func send(_ action: Action) {
    actionDispatcher.send(action)
    self.didDispatchActionPublisher.send()
  }
  
  func proxy(modifyAction: ActionModifier?) -> ActionDispatcher {
    actionDispatcher.proxy(modifyAction: modifyAction)
  }
}
