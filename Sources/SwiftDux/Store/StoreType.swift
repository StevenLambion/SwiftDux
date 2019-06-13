import Foundation
import Combine

public protocol StoreType: class, ActionPlanDispatcher {
  var state: State { get }
  var didChangeWithAction: AnyPublisher<Action, Never> { get }
  var didChange: AnyPublisher<Void, Never> { get }
}

extension StoreType {
  
  public func send(_ actionPlan: ActionPlan<State>) {
    let dispatch: ActionPlanDispatch = { [unowned self] in self.send($0) }
    let getState: GetState = { [unowned self] in self.state }
    actionPlan(dispatch, getState)
  }
  
  @discardableResult
  public func send<P>(
    _ actionPlan: PublishableActionPlan<State,P>
    ) -> AnyPublisher<Void, Never> where P : Publisher, P.Failure == Never, P.Output == Action?
  {
    let dispatch: ActionPlanDispatch = { [unowned self] in self.send($0) }
    let getState: GetState = { [unowned self] in self.state }
    let publisher  = actionPlan(dispatch, getState)
    publisher.compactMap { $0 }.subscribe(self)
    return publisher.map { _ in () }.eraseToAnyPublisher()
  }
  
  public func on<A, T>(action: A.Type, mapState: @escaping (State) -> T) -> AnyPublisher<T, Never> where A: Action {
    return didChangeWithAction
      .filter { $0 is A }
      .map { [unowned self] _ in mapState(self.state ) }
      .eraseToAnyPublisher()
  }
  
  public func mapState<T>(_ mapState: @escaping (State) -> T) -> AnyPublisher<T, Never> where T: Equatable {
    return didChangeWithAction
      .map { [unowned self] _ in mapState(self.state ) }
      .removeDuplicates()
      .eraseToAnyPublisher()
  }
  
}
