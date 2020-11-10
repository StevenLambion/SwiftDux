import SwiftUI

/// A view modifier that connects to the application state.
public protocol ConnectableViewModifier: ViewModifier, Connectable {
  associatedtype InnerBody: View
  associatedtype Body = Connector<InnerBody, State, Props>

  /// Return the body of the view modifier using the provided props object.
  /// - Parameters:
  ///   - props: A mapping of the application to the props used by the view.
  ///   - content: The content of the view modifier.
  /// - Returns: The connected view.
  func body(props: Props, content: Content) -> InnerBody
}

extension ConnectableViewModifier {

  public func body(content: Content) -> Connector<InnerBody, State, Props> {
    Connector(mapState: map) { props in
      body(props: props, content: content)
    }
  }
}
