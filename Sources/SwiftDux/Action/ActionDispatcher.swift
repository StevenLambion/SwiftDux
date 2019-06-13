import Foundation
import Combine

/// Specifies a type as a dispatchable action. Typically this is done with enum types,
/// however,  it could be added to protocols or structs if a more complex solution is needed.
///
/// Enum Example:
/// ```
///   enum TodoList: Action {
///     case setItems(items: [TodoItem])
///     case addItem(withText: String)
///     case removeItems(at: IndexSet)
///     case moveItems(at: IndexSet, to: Int)
///   }
/// ```
public protocol Action {}

/// A noop action used by reducers that may not have their own actions. These reducers
/// typically act as routers, sending dispatched actions to subreducers.
public struct EmptyAction: Action {}

/// An object that dispatches actions to a state reducer.
public protocol ActionDispatcher: Subscriber {
  
  /// Sends an action to a reducer to mutate the state of the application.
  func send(_ action: Action)
  
}

/// Default implementation of Subscriber that allows action dispatchers to subscribe to
/// an external action publisher. This simplifies the transformation of external events, such
/// as user input or notifications, to actions sent directly to a dispatcher.
extension ActionDispatcher {
  
  public func receive(_ input: Action) -> Subscribers.Demand {
    self.send(input)
    return .unlimited
  }
  
  public func receive(completion: Subscribers.Completion<Never>) {
    switch completion {
    case .finished:
      break
    case .failure:
      fatalError("This should never be called.")
    }
  }
  
  public func receive(subscription: Subscription) {
    subscription.request(.unlimited)
  }
  
}
