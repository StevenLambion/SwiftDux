import SwiftUI
import Combine

extension Store: BindableObject {}

/// Provides the application's store to views in the environment.
///
/// Typically you should use the `Store<_>.connect(updateOn:wrapper:)` method.
internal class DispatcherContext : BindableObject {
  public var didChange = PassthroughSubject<Void, Never>()
  public var dispatcher: ActionDispatcher {
    didSet { didChange.send() }
  }

  public init(dispatcher: ActionDispatcher) {
    self.dispatcher = dispatcher
  }
}

/// A view modifier that injects a store into the environment. Use the
/// `View.provideStore(_:)`` method instead of this type directly.
public struct StoreProvider<State> : ViewModifier where State : StateType {

  private var store: Store<State>
  private var stateContext: StateContext<State>
  private var dispatcherContext: DispatcherContext

  public init(store: Store<State>) {
    self.store = store
    self.stateContext = StateContext(
      didChangeWithActionPublisher: store.didChangeWithAction,
      didChangePublisher: Publishers.Empty().eraseToAnyPublisher(),
      state: store.state
    )
    self.dispatcherContext = DispatcherContext(dispatcher: store.proxy())
  }

  public func body(content: Content) -> some View {
    content
      .environmentObject(store)
      .environmentObject(stateContext)
      .environmentObject(dispatcherContext)
  }

}

public struct DispatchProxy: ViewModifier {
  @EnvironmentObject var dispatcherContext: DispatcherContext

  var modifyAction: ActionModifier? = nil

  public init(modifyAction: ActionModifier? = nil) {
    self.modifyAction = modifyAction
  }

  public func body(content: Content) -> some View {
    let dispatcher = dispatcherContext.dispatcher.proxy(modifyAction: modifyAction)
    return content
      .environmentObject(DispatcherContext(dispatcher: dispatcher))
  }

}

extension View {

  /// Injects a store into the environment. The store can then be used by the `@EnvironmentObject`
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
  public func provideStore<State>(_ store: Store<State>) -> Self.Modified<StoreProvider<State>> where State : StateType {
    return self.modifier(StoreProvider<State>(store: store))
  }

  /// Create a new `StoreActionDispatcher<_>` that proxies off of the current one in the environment. Actions will be modified
  /// by both the new proxy and the original dispatcher it was created from.
  /// - Parameter stateType: Used to find the current dispatcher in the environment.
  /// - Parameter modifyAction: A closure to modify the action before it continues up stream.
  public func modifyActions(_ modifier: ActionModifier? = nil) -> some View {
    return self.modifier(DispatchProxy(modifyAction: modifier))
  }

}
