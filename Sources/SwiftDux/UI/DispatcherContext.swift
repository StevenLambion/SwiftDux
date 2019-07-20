import SwiftUI
import Combine

/// Provides the application's store to views in the environment.
///
/// Typically you should use the `Store<_>.connect(updateOn:wrapper:)` method.
public class DispatcherContext : BindableObject {
  public var willChange = PassthroughSubject<Void, Never>()
  var dispatcher: ActionDispatcher {
    willSet { willChange.send() }
  }
  
  init(dispatcher: ActionDispatcher) {
    self.dispatcher = dispatcher
  }
}
