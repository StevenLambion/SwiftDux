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

  public func run<T>(store: Store<T>) -> AnyPublisher<Action, Never> {
    actions
      .publisher
      .flatMap(maxPublishers: .max(1)) { action in
        self.run(action: action, forStore: store)
      }
      .eraseToAnyPublisher()
  }

  private func run<T>(action: Action, forStore store: Store<T>) -> AnyPublisher<Action, Never> {
    if let action = action as? RunnableAction {
      return action.run(store: store)
    }
    return Just(action).eraseToAnyPublisher()
  }

  /// Chains an array of actions to be dispatched next.
  ///
  /// - Parameter actions: An array of actions to chain together.
  /// - Returns: A composite action.
  @inlinable public func then(_ actions: [Action]) -> CompositeAction {
    var nextAction = self
    nextAction.actions += actions
    return nextAction
  }

  /// Chains an array of actions to be dispatched next.
  ///
  /// - Parameter actions: One or more actions to chain together.
  /// - Returns: A composite action.
  @inlinable public func then(_ actions: Action...) -> CompositeAction {
    then(actions)
  }

  /// Call the provided block next.
  ///
  /// - Parameter block: A block of code to execute once the previous action has completed.
  /// - Returns: A composite action.
  @inlinable public func then(_ block: @escaping () -> Void) -> CompositeAction {
    then(ActionPlan<Any> { _ in block() })
  }
}
