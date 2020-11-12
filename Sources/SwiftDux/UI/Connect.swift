import Combine
import Foundation
import SwiftUI

/// Connects the application state to a view.
/// ```
/// struct MyView : View {
///   @Connect(map) var todoList: TodoList
///
///   static func map(state: AppState) -> TodoList {
///     state.todoList
///   }
/// }
/// ```
@propertyWrapper
public struct Connect<State, Props>: DynamicProperty where Props: Equatable {
  @Environment(\.store) private var anyStore
  @StateObject private var propsHolder = PropsHolder<Props>()
  private var mapState: (State, ActionBinder) -> Props?

  public var wrappedValue: Props {
    guard let props = propsHolder.props else {
      fatalError("Tried mapping the state to a view, but the Store<_> doesn't conform to '\(State.self)'")
    }
    return props
  }

  public var projectedValue: Binding<Props> {
    Binding<Props>(
      get: { wrappedValue },
      set: { _ in }
    )
  }

  /// Connect the application state to the view with a mapping function.
  ///
  /// - Parameter mapState: Map the state to a view-specific props object.
  public init(_ mapState: @escaping (State) -> Props?) {
    self.mapState = { state, _ in mapState(state) }
  }

  /// Connect the application state to the view with a mapping function.
  ///
  /// - Parameter mapState: Map the state to a view-specific props object.
  public init(_ mapState: @escaping (State, ActionBinder) -> Props?) {
    self.mapState = mapState
  }

  public mutating func update() {
    if let store = anyStore.unwrap(as: State.self) {
      propsHolder.subscribe(to: store) { [mapState] in
        mapState($0, ActionBinder(actionDispatcher: store))
      }
    }
  }
}

extension Connect {

  private final class PropsHolder<Props>: ObservableObject where Props: Equatable {
    @Published var props: Props? = nil
    var cancellable: AnyCancellable? = nil

    func subscribe<State>(to store: StoreProxy<State>, mapState: @escaping (State) -> Props?) {
      guard cancellable == nil else { return }
      cancellable = store.publish(mapState).sink { self.props = $0 }
    }
  }
}
