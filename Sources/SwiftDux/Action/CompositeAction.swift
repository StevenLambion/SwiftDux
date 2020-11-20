import Combine
import Foundation

/// Combines multiple actions into a chained, composite action. It guarantees the dispatch order of each action.
public struct CompositeAction: RunnableAction {

  @usableFromInline
  internal var actions: [Action] = []

  /// Create a composite action.
  ///
  /// - Parameter actions: An array of actions to chain.
  @usableFromInline internal init(_ actions: [Action] = []) {
    self.actions = actions
  }

  public func run<T>(store: StoreProxy<T>) -> AnyPublisher<Action, Never> {
    actions
      .publisher
      .flatMap(maxPublishers: .max(1)) { action in
        self.run(action: action, forStore: store)
      }
      .eraseToAnyPublisher()
  }

  private func run<T>(action: Action, forStore store: StoreProxy<T>) -> AnyPublisher<Action, Never> {
    if let action = action as? RunnableAction {
      return action.run(store: store)
    }
    return Just(action).eraseToAnyPublisher()
  }
}


/// Chain two actions together as a composite type.
///
/// - Parameters:
///   - lhs: The first action.
///   - rhs: The next action.
/// - Returns: A composite action.
@inlinable public func + (lhs: Action, rhs: Action) -> CompositeAction {
  if var lhs = lhs as? CompositeAction {
    lhs.actions.append(rhs)
    return lhs
  }
  return CompositeAction([lhs, rhs])
}
