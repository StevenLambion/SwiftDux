import Foundation
import Combine

public final class StoreDispatcher<State> : ActionPlanDispatcher where State : StateType {
  
  public typealias ActionModifier = (Action) -> Action?
  
  private let upstream: Store<State>
  private let upstreamActionSubject: PassthroughSubject<Action, Never>
  private let modifyAction: ActionModifier?
  
  public init(upstream: Store<State>, upstreamActionSubject: PassthroughSubject<Action, Never>, modifyAction: ActionModifier? = nil) {
    self.upstream = upstream
    self.upstreamActionSubject = upstreamActionSubject
    self.modifyAction = modifyAction
  }
  
  public func send(_ action: Action) {
    if let modifyAction = modifyAction, let newAction = modifyAction(action) {
      upstream.send(newAction)
      upstreamActionSubject.send(action)
    } else {
      upstream.send(action)
    }
  }
  
  public func send(_ actionPlan: ActionPlan<State>) {
    let dispatch: ActionPlanDispatch = { [unowned self] in self.send($0) }
    let getState: GetState = { [unowned upstream] in upstream.state }
    actionPlan(dispatch, getState)
  }
  
  public func send(_ actionPlan: PublishableActionPlan<State>) -> AnyPublisher<Void, Never> {
    let dispatch: ActionPlanDispatch = { [unowned self] in self.send($0) }
    let getState: GetState = { [unowned upstream] in upstream.state }
    let publisher  = actionPlan(dispatch, getState)
    publisher.compactMap { $0 }.subscribe(self)
    return publisher.map { _ in () }.eraseToAnyPublisher()
  }
  
}

extension StoreDispatcher {
  
  func proxy(modifyAction: ActionModifier? = nil) -> StoreDispatcher<State> {
    let upstreamModifyAction = self.modifyAction
    var modifyActionWrapper = upstreamModifyAction
    if let modifyAction = modifyAction {
      modifyActionWrapper = {
        if let action = modifyAction($0) {
          return upstreamModifyAction?(action) ?? action
        }
        return nil
      }
    }
    return StoreDispatcher<State>(
      upstream: self.upstream,
      upstreamActionSubject: self.upstreamActionSubject,
      modifyAction: modifyActionWrapper
    )
  }
  
}
