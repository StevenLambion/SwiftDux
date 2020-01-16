import Combine
import Foundation

internal final class DispatchConnection: ActionDispatcher {
  var didDispatchAction = ObservableObjectPublisher()

  private var actionDispatcher: ActionDispatcher

  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher.proxy(modifyAction: nil) { [didDispatchAction] _ in
      didDispatchAction.send()
    }
  }

  func send(_ action: Action) {
    actionDispatcher.send(action)
  }

  func proxy(modifyAction: ActionModifier?, sentAction: ((Action) -> Void)?) -> ActionDispatcher {
    actionDispatcher.proxy(modifyAction: modifyAction, sentAction: sentAction)
  }
}
