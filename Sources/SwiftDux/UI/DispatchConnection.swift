import Foundation
import Combine

internal final class DispatchConnection: ActionDispatcher, Subscriber {
  var didDispatchAction = ObservableObjectPublisher()

  private var actionDispatcher: ActionDispatcher!

  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher.proxy(modifyAction: nil) { [weak self] _ in
      self?.didDispatchAction.send()
    }
  }

  func send(_ action: Action) {
    actionDispatcher.send(action)
  }

  func proxy(modifyAction: ActionModifier?, sentAction: ((Action) -> ())?) -> ActionDispatcher {
    actionDispatcher.proxy(modifyAction: modifyAction, sentAction: sentAction)
  }
}
