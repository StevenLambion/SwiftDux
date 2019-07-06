import Foundation
import Combine

/// Used internally to wrap modified actions. This allows the store to publish changes in the correct order that actions were sent.
public struct ModifiedAction : Action {
  public var action: Action
  public var previousActions: [Action]
  
  public init(action: Action, previousActions: [Action] = []) {
    self.action = action
    self.previousActions = previousActions
  }
  
  public init(action: Action, previousAction: Action) {
    self.action = action
    
    if let previousAction = previousAction as? ModifiedAction {
      self.previousActions = previousAction.previousActions + [previousAction.action]
    } else {
      self.previousActions = [previousAction]
    }
  }
  
  public func modified(with newAction: Action) -> ModifiedAction {
    var newPreviousActions = previousActions
    newPreviousActions.append(action)
    return ModifiedAction(
      action: newAction,
      previousActions: newPreviousActions
    )
  }
}
