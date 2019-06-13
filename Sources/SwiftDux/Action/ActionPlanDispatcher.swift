import Foundation
import Combine

/// A closure that returns the current state of a store.
public typealias GetState<State> = () -> State where State : StateType

/// A closure that dispatches an action
public typealias ActionPlanDispatch = (Action) -> ()


/// Encapsulates multiple actions into a packaged up "action plan"
///
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
///
/// - parameters:
///   - store: The store containing the application's state.
public typealias ActionPlan<State> = (ActionPlanDispatch, GetState<State>) -> ()where State : StateType

/// An action plan that may optionally publish actions to the store. The send method of the action
/// dispatcher  returns back a publisher to allow events to be triggered when an action is sent or
/// the publisher has completed.
/// - parameters:
///   - store: The store containing the application's state.
/// - returns: A publisher that can send actions to the store
public typealias PublishableActionPlan<State, P> = (ActionPlanDispatch, GetState<State>) -> P
  where State : StateType, P : Publisher, P.Output == Action?, P.Failure == Never

/// Dispatches action plans with the same interface signature as regular actions. This allows
/// the ability to incapsulate complex workflows that may require many actions and external events
/// to be  self-contained in a single package.
public protocol ActionPlanDispatcher: ActionDispatcher {
  
  /// The state that will be mutated by a dispatched action. This is nessesary to
  /// provide action plans with context of the current state when determining the
  /// path to take in their workflow.
  associatedtype State: StateType
  
  /// Sends a self-contained action plan to mutate the application's state. Action plans are typically
  /// used when multiple actions must be dispatched or there's asynchronous actions that must be
  /// performed.
  ///
  /// The dispatching of actions should always be done on the main thread. Action plans can be used
  /// to offload to other threads to perform complex workflows before pushing the changes into the state
  /// on the main thread.
  func send(_ actionPlan: ActionPlan<State>)
  
  /// Sends a self contained action plan that the dispatcher can subscribe to. The plan may still send
  /// actions directly to the store object, or it may opt to publish them. In most cases, there should be
  /// at least one published action.
  ///
  /// The caller to the method will recieve an optional publisher to notify it that an action was sent. It can
  /// also be used to signify the completion of the action plan to allow the trigger of external events or side
  /// effects that are unable to be performed from at the state level.
  @discardableResult
  func send<P>(_ actionPlan: PublishableActionPlan<State,P>) -> AnyPublisher<Void, Never>
    where P : Publisher, P.Output == Action?, P.Failure == Never
  
}
