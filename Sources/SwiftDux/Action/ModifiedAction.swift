import Combine
import Foundation

/// Used internally to wrap modified actions. This allows the store to publish changes in the correct order that actions were sent.
internal struct ModifiedAction: Action {
  var action: Action
  var previousActions: [Action]

  init(action: Action, previousActions: [Action] = []) {
    self.action = action
    self.previousActions = previousActions
  }

  init(action: Action, previousAction: Action) {
    self.action = action

    if let previousAction = previousAction as? ModifiedAction {
      self.previousActions = previousAction.previousActions + [previousAction.action]
    } else {
      self.previousActions = [previousAction]
    }
  }

  func modified(with newAction: Action) -> ModifiedAction {
    var newPreviousActions = previousActions
    newPreviousActions.append(action)
    return ModifiedAction(
      action: newAction,
      previousActions: newPreviousActions
    )
  }
}
