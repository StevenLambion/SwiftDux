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
  
  public func bind<T>(_ mapState: @escaping (State) -> T, update: @escaping (T) -> Action) -> Binding<T> {
    return Binding<T>(
      getValue: { mapState(self.value) } ,
      setValue: { self.storeContext.dispatcher.send(update($0)) }
    )
  }
  
}
