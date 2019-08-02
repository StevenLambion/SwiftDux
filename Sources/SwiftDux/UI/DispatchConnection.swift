import Foundation
import Combine

final internal class DispatchConnection : ObservableObject, Identifiable {
  var actionDispatcher: ActionDispatcher?
  
  /// Required to cause a SwiftUI update. Sending directly to the objectWIllChange publisher has no effect
  /// without some kind of state change.
  @Published var causeRefresh: Action = EmptyAction()
  
  func send(action: Action) {
    actionDispatcher?.send(action)
    causeRefresh = EmptyAction()
  }
}
