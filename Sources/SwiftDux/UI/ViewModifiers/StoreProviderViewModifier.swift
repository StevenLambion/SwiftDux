import Combine
import SwiftUI

/// A view modifier that injects a store into the environment.
public struct StoreProviderViewModifier<State>: ViewModifier {
  private var storeWrapper: StoreWrapper<State>

  @usableFromInline internal init(store: StoreProxy<State>) {
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
  /// }
  /// ```
  /// - Parameter store: The store object to inject.
  /// - Returns: The modified view.
  public func provideStore<State>(_ store: Store<State>) -> some View where State: StateType {
    return modifier(StoreProviderViewModifier<State>(store: store.proxy(for: State.self)!))
  }

  /// Injects a store into the environment as a specific type.
  ///
  /// This is useful if a protocol is used to retreive the state in a `ConnectableView`. It can be used multiple times
  /// to provide support for protocols that the store might adhere to.
  /// struct RootView: View {
  ///   // Passed in from the AppDelegate or SceneDelegate class.
  ///   var store: Store<AppState>
  ///
  ///
  ///   var body: some View {
  ///     RootAppNavigation()
  ///       .provideStore(store)
  ///       .provideStore(store, as: NavigationStateRoot.self)
  ///   }
  /// }
  /// ```
  /// - Parameters:
  ///   - store: The store object to inject.
  ///   - type: A type that the store adheres to.
  /// - Returns: The modified view.
  public func provideStore<State, Substate>(_ store: Store<State>, as type: Substate.Type) -> ModifiedContent<Self, StoreProviderViewModifier<Substate>>
  where State: StateType {
    // FIXME - Added concrete return type due to a bug that causes segment faults in release builds.
    return modifier(StoreProviderViewModifier<Substate>(store: store.proxy(for: type.self)!))
  }
}
