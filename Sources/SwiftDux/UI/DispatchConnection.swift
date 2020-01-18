import Combine
import Foundation

internal final class DispatchConnection: ActionDispatcher, ObservableObject {
  var objectWillChange = ObservableObjectPublisher()

  private var actionDispatcher: ActionDispatcher

  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher.proxy(modifyAction: nil) { [objectWillChange] _ in
      objectWillChange.send()
    }
  }

  func send(_ action: Action) {
    actionDispatcher.send(action)
  }

  func proxy(modifyAction: ActionModifier?, sentAction: ((Action) -> Void)?) -> ActionDispatcher {
    actionDispatcher.proxy(modifyAction: modifyAction, sentAction: sentAction)
  }
}
