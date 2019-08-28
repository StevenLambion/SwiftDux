import Foundation
import Combine

/// Middleware perform actions on the the store when actions are dispatched to it.
///
/// Before an action is given to a reducer, middleware have an opportunity to handle it
/// themselves. They may dispatch their own actions, transform the current action, or
/// block an incoming ones from continuing.
///
/// Middleware can also be used to set up external hooks from services.
///
/// For a reducer's own state and actions, implement the `reduce(state:action:)`.
/// For subreducers, implement the `reduceNext(state:action:)` method.
public typealias Middleware<State: StateType> = (StoreProxy<State>) -> SendAction
