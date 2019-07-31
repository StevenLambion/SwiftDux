import SwiftUI

/// Connects the store's state to a view.
///
/// A connector should be created as a singleton. It creates a stateless mechanism to update the connected view when the provided filter function returns
/// true.
/// ```
/// struct BookListContainer : View {
///   ...
/// }
///
/// extension BookListContainer {
///
///   static let connector = Connector<AppState> { $0 is BookListAction }
///
///   static func connected() -> some View {
///     connector.mapToView { state, dispatcher in
///       BookListContainer(
///         books: state.books
///         onAddBook: { dispatcher.send(BookListAction.addBook($0) }
///       )
///     }
///   }
///
/// }
/// ```
@available(*, deprecated, message: "Use the Connectable API instead.")
public final class Connector<State> where State : StateType {
  
  private let filter: (Action) -> Bool
  
  public init(updateWhen filter: @escaping (Action) -> Bool) {
    self.filter = filter
  }
  
  public func mapToView<Content>(content: @escaping (State, ActionDispatcher) -> Content?) -> AnyView where Content : View {
    AnyView(ConnectorView(content: content).connect(updateWhen: filter) { (state: State) in state })
  }
  
}
