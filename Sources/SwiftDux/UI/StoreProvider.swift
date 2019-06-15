import SwiftUI
import Combine

public class StoreContext<S>: BindableObject where S : StateType {
  public var didChange = PassthroughSubject<Void, Never>()
  public var store: Store<S>
  public var dispatcher: StoreDispatcher<S>
  
  internal init(store: Store<S>, dispatcher: StoreDispatcher<S>) {
    self.store = store
    self.dispatcher = dispatcher
  }
}

private struct StoreProvider<S>: ViewModifier where S : StateType {
  
  private var storeContext: StoreContext<S>
  
  public init(store: Store<S>, modifyAction: StoreDispatcher<S>.ActionModifier? = nil) {
    self.storeContext = StoreContext(store: store, dispatcher: store.dispatcher(modifyAction: modifyAction))
  }
  
  public func body(content: Content) -> some View {
    content.environmentObject(storeContext)
  }
  
}

private struct DispatchProxy<S>: ViewModifier where S : StateType {
  @EnvironmentObject var storeContext: StoreContext<S>
  
  var modifyAction: StoreDispatcher<S>.ActionModifier? = nil
  
  public init(modifyAction: StoreDispatcher<S>.ActionModifier? = nil) {
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
  ///
  /// - Parameter store: The store object to inject.
  public func provideStore<S>(_ store: Store<S>, modifyAction: StoreDispatcher<S>.ActionModifier? = nil) -> some View where S: StateType {
    return self.modifier(StoreProvider(store: store, modifyAction: modifyAction))
  }
  
  public func proxyDispatch<S>(for stateType: S.Type, modifyAction: @escaping StoreDispatcher<S>.ActionModifier) -> some View where S: StateType {
    return self.modifier(DispatchProxy<S>(modifyAction: modifyAction))
  }
}
