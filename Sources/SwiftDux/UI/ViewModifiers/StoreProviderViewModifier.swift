import Combine
import SwiftUI

/// A view modifier that injects a store into the environment.
public struct StoreProviderViewModifier<State>: ViewModifier where State: StateType {
  private var storeWrapper: StoreWrapper<State>

  @usableFromInline internal init(store: Store<State>) {
    self.storeWrapper = StoreWrapper(store: store)
  }

  public func body(content: Content) -> some View {
    content
      .environmentObject(storeWrapper)
      .environment(\.actionDispatcher, storeWrapper.store)
  }
}

extension View {

  /// Injects a store into the environment.
  ///
  /// The store can then be used by the `@EnvironmentObject`
  /// property wrapper. This method also enables the use of `View.mapState(updateOn:_:)` to
  /// map substates to a view.
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
  /// - Returns: The modified view.
  @inlinable public func provideStore<State>(_ store: Store<State>) -> some View where State: StateType {
    return modifier(StoreProviderViewModifier<State>(store: store))
  }
}
