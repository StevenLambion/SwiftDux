import SwiftUI
import Combine

public class StoreContext<State> : BindableObject where State : StateType {
  public var didChange = PassthroughSubject<Void, Never>()
  public var store: Store<State> {
    didSet { didChange.send(()) }
  }
  
  internal init(store: Store<State>) {
    self.store = store
  }
}

public struct StoreProvider<State> : ViewModifier where State : StateType {
  
  private var storeContext: StoreContext<State>
  
  public init(store: Store<State>) {
    self.storeContext = StoreContext(store: store)
  }
  
  public func body(content: Content) -> some View {
    content.environmentObject(storeContext)
  }
  
}

extension View {
  
  /// Injects a store into the environment. The store is then used by the `Store<State>.connect()`
  /// method to connect the state to a view.
  ///
  /// - Parameter store: The store object to inject.
  public func provideStore<State>(_ store: Store<State>) -> some View where State : StateType {
    return self.modifier(StoreProvider(store: store))
  }
  
}
