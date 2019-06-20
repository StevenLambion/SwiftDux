import Foundation
import SwiftUI

/// Retrieves the current application state from thje environment and maps it to a property in a SwiftUI view.
/// ```
/// struct MyView : View {
///
///   @MapState var state: AppState
///
/// }
/// ```
@propertyDelegate
public struct MapState<State: StateType> : DynamicViewProperty {

  @EnvironmentObject private var storeContext: StoreContext<State>

  public var value: State {
    nonmutating get {
      storeContext.store.state
    }
  }

  public init() {}

  /// Create a binding for a mapped state value and an action.
  /// - Parameters:
  ///   - mapState: A mapper that returns the value from the current state.
  ///   - update: A closure that maps the new value to an action to dispatch the change.
  /// - Returns: A new `Binding<_>` of the state value.
  public func bind<T>(_ mapState: @escaping (State) -> T, update: @escaping (T) -> Action) -> Binding<T> {
    return Binding<T>(
      getValue: { mapState(self.value) } ,
      setValue: { self.storeContext.dispatcher.send(update($0)) }
    )
  }

}
