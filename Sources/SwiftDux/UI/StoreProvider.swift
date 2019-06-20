import SwiftUI
import Combine

extension Store: BindableObject {}

internal class StoreDispatcherContext<State> : BindableObject where State : StateType {
  public var didChange = PassthroughSubject<Void, Never>()
  public var dispatcher: StoreActionDispatcher<State> {
    didSet { didChange.send() }
  }
  
  public init(dispatcher: StoreActionDispatcher<State>) {
    self.dispatcher = dispatcher
  }
}

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
  private var storeDispatcherContext: StoreDispatcherContext<State>
  private var dispatcherContext: DispatcherContext

  public init(store: Store<State>) {
    self.store = store
    self.stateContext = StateContext(
      didChangeWithActionPublisher: store.didChangeWithAction,
      didChangePublisher: Publishers.Empty().eraseToAnyPublisher(),
      state: store.state
    )
    let dispatcher = store.dispatcher()
    self.storeDispatcherContext = StoreDispatcherContext(dispatcher: dispatcher)
    self.dispatcherContext = DispatcherContext(dispatcher: dispatcher)
  }

  public func body(content: Content) -> some View {
    content
      .environmentObject(store)
      .environmentObject(stateContext)
      .environmentObject(storeDispatcherContext)
      .environmentObject(dispatcherContext)
  }

}

public struct DispatchProxy<State>: ViewModifier where State : StateType {
  @EnvironmentObject var storeDispatcherContext: StoreDispatcherContext<State>

  var modifyAction: StoreActionDispatcher<State>.ActionModifier? = nil

  public init(modifyAction: StoreActionDispatcher<State>.ActionModifier? = nil) {
    self.modifyAction = modifyAction
  }

  public func body(content: Content) -> some View {
    let dispatcher = storeDispatcherContext.dispatcher.proxy(modifyAction: modifyAction)
    return content
      .environmentObject(StoreDispatcherContext(dispatcher: dispatcher))
      .environmentObject(DispatcherContext(dispatcher: dispatcher))
  }

}

extension View {

  /// Injects a store into the environment. The store can then be used by the `@EnvironmentObject`
  /// property wrapper. This method also enables the use of `View.mapState(from:for:_:)` to
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
  public func proxyDispatch<S>(for stateType: S.Type, modifyAction: @escaping StoreActionDispatcher<S>.ActionModifier) -> some View where S: StateType {
    return self.modifier(DispatchProxy<S>(modifyAction: modifyAction))
  }

}
