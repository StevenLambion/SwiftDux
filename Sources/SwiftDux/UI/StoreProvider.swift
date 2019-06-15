import SwiftUI
import Combine

public class StoreContext<S> : BindableObject where S : StateType {
  public var didChange = PassthroughSubject<Void, Never>()
  public var store: Store<S>
  
  internal init(store: Store<S>) {
    self.store = store
  }
}

private struct StoreProvider<S> : ViewModifier where S : StateType {
  
  private var storeContext: StoreContext<S>
  
  public init(store: Store<S>) {
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
  public func provideStore<S>(_ store: Store<S>) -> some View where S : StateType {
    return self.modifier(StoreProvider(store: store))
  }
  
}
