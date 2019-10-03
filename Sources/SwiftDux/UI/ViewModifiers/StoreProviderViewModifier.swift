import Combine
import SwiftUI

/// A view modifier that injects a store into the environment.
internal struct StoreProviderViewModifier<State>: ViewModifier where State: StateType {

  private var store: Store<State>
  private var connection: StateConnection<State>
  private var actionDispatcher: ActionDispatcher

  internal init(store: Store<State>) {
    self.store = store
    self.connection
      = StateConnection<State>(
        getState: { [weak store] in
          guard let store = store else { return nil }
          return store.state
        },
        changePublisher: store.didChange
          .filter { $0 is StoreAction<State> }
          .map { _ in }
          .eraseToAnyPublisher()
      )
    self.actionDispatcher = store.proxy()
  }

  public func body(content: Content) -> some View {
    content
      .environmentObject(connection)
      .environment(\.actionDispatcher, actionDispatcher)
      .environment(\.storeUpdated, store.didChange)
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
  @available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
  public func provideStore<State>(_ store: Store<State>) -> some View where State: StateType {
    return modifier(StoreProviderViewModifier<State>(store: store))
  }

}
