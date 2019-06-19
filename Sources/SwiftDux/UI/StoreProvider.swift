import SwiftUI
import Combine

/// Provides the application's store to views in the environment.
///
/// Typically you should use the `Store<_>.connect(updateOn:wrapper:)` method.
internal class StoreContext<State> : BindableObject where State : StateType {
  public var didChange = PassthroughSubject<Void, Never>()

  /// The current store in the environment.
  public var store: Store<State> {
    didSet { didChange.send(()) }
  }

  public var dispatcher: StoreActionDispatcher<State> {
    didSet { didChange.send(()) }
  }

  public init(store: Store<State>, dispatcher: StoreActionDispatcher<State>) {
    self.store = store
    self.dispatcher = dispatcher
  }
}

/// A view modifier that injects a store into the environment. Use the
/// `View.provideStore(_:)`` method instead of this type directly.
public struct StoreProvider<State> : ViewModifier where State : StateType {

  private var storeContext: StoreContext<State>

  public init(store: Store<State>) {
    self.storeContext = StoreContext(store: store, dispatcher: store.dispatcher())
  }

  public func body(content: Content) -> some View {
    content.environmentObject(storeContext)
  }

}

private struct DispatchProxy<S>: ViewModifier where S : StateType {
  @EnvironmentObject var storeContext: StoreContext<S>

  var modifyAction: StoreActionDispatcher<S>.ActionModifier? = nil

  public init(modifyAction: StoreActionDispatcher<S>.ActionModifier? = nil) {
    self.modifyAction = modifyAction
  }

  public func body(content: Content) -> some View {
    content.environmentObject(StoreContext(
      store: storeContext.store,
      dispatcher: storeContext.dispatcher.proxy(modifyAction: modifyAction)
    ))
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
  public func provideStore<State>(_ store: Store<State>) -> Self.Modified<StoreProvider<State>> where State : StateType {
    return self.modifier(StoreProvider<State>(store: store))
  }

  /// Create a new `StoreActionDispatcher<_>` that proxies off of the current one in the environment. Actions will be modified
  /// by both the new proxy and the original dispatcher it was created from.
  /// - Parameter stateType: Used to find the current dispatcher in the environment.
  /// - Parameter modifyAction: A closure to modify the action before it continues up stream.
  public func proxyDispatch<S>(for stateType: S.Type, modifyAction: @escaping StoreActionDispatcher<S>.ActionModifier) -> some View where S: StateType {
    return self.modifier(DispatchProxy<S>(modifyAction: modifyAction))
  }
}
