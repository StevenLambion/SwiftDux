import SwiftUI
import Combine

/// Provides the application's store to views in the environment.
///
/// Typically you should use the `Store<_>.connect(updateOn:wrapper:)` method.
internal class DispatcherContext : BindableObject {
  var didChange = PassthroughSubject<Void, Never>()
  var dispatcher: ActionDispatcher {
    didSet { didChange.send() }
  }
  
  init(dispatcher: ActionDispatcher) {
    self.dispatcher = dispatcher
  }
}
