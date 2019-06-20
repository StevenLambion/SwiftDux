import Foundation
import Combine

/// A closure that returns the current state of a store.
public typealias GetState<State> = () -> State where State : StateType

/// A closure that dispatches an action
/// - Parameter action: Dispatches the given state synchronously.
public typealias Dispatch = (Action) -> ()


/// Encapsulates multiple actions into a packaged up "action plan"
///```
///   struct UserActionPlans {
///
///     static func getUser(byId id: String) -> ActionPlan<AppState> {
///       return { dispatch, getState in
///         guard !getState().users.hasValue(id) else { return }
///         dispatch(UserAction.setLoading(true))
///         let sink = UserService.getUser(id)
///           .map { UserAction.setUser($0) }
///           .subscribe {
///             dispatch($0),
///             dispatch(UserAction.setLoading(false))
///           }
///        defer { sink.cancel() }
///       }
///     }
///
///   }
///
///   // Somewhere inside a view:
///
///   func loadUser() {
///     dispatcher.send(UserActionPlans.getUser(self.id))
///   }
///```
/// - Parameters:
///   - dispatch: Dispatches an action synchronously.
///   - getState: Gets the latest snapshot of the application's state.
public struct ActionPlan<State> : Action where State : StateType {
  public typealias Body = (Dispatch, GetState<State>) -> ()
  
  var body: Body
  
  public init(_ body: @escaping Body) {
    self.body = body
  }
}

/// An action plan that may optionally publish actions to the store. The send method of the action
/// dispatcher  returns back a publisher to allow events to be triggered when an action is sent or
/// the publisher has completed.
/// - Parameters:
///   - dispatch: Dispatches an action synchronously.
///   - getState: Gets the latest snapshot of the application's state.
/// - Returns: A publisher that can send actions to the store.
public struct PublishableActionPlan<State> : Action where State : StateType {
  public typealias Body = (Dispatch, GetState<State>) -> AnyPublisher<Action?, Never>
  
  var body: Body
  
  public init(_ body: @escaping Body) {
    self.body = body
  }
}
