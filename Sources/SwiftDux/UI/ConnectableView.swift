import SwiftUI

/// A view that connects to the application state.
public protocol ConnectableView: View, Connectable {
  associatedtype Content: View
  associatedtype Body = Connector<Content, State, Props>

  /// Return the body of the view using the provided props object.
  /// - Parameter props: A mapping of the application to the props used by the view.
  /// - Returns: The connected view.
  func body(props: Props) -> Content
}

extension ConnectableView {

  public var body: Connector<Content, State, Props> {
    Connector(mapState: map, content: body)
  }
}
