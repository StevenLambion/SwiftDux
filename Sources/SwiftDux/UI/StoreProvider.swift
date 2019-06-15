import SwiftUI
import Combine

/// Provides the application's store to views in the environment.
///
/// Typically you should use the `Store<_>.connect(updateOn:wrapper:)` method.
public class StoreContext<State> : BindableObject where State : StateType {
  public var didChange = PassthroughSubject<Void, Never>()
  
  /// The current store in the environment.
  public var store: Store<State> {
    didSet { didChange.send(()) }
  }
  
  internal init(store: Store<State>) {
    self.store = store
  }
}

private struct StoreProvider<State> : ViewModifier where State : StateType {
  
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
  /// ```
  /// struct RootView: View {
  ///   // Passed in from the AppDelegate or SceneDelegate class.
  ///   var store: Store<AppState>
  ///
  ///
  ///   var body: some View {
  ///     RootAppNavigation()
  ///       .provideStore(store)
  ///   }
  ///
  /// }
  /// ```
  /// - Parameter store: The store object to inject.
  public func provideStore<State>(_ store: Store<State>) -> some View where State : StateType {
    return self.modifier(StoreProvider(store: store))
  }
  
}
