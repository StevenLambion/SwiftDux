import SwiftUI

/// A view that connects to the application state.
public protocol ConnectableView: View, Connectable {
  associatedtype Content: View
  associatedtype Body = Connector<Content, Superstate, Props>

  /// Return the body of the view using the provided props object.
  /// - Parameter props: A mapping of the application to the props used by the view.
  /// - Returns: The connected view.
  func body(props: Props) -> Content
}

extension ConnectableView {

  /// Concrete return type is nessarry to avoid segment fault in release builds of apps.
  public var body: Connector<Content, Superstate, Props> {
    Connector<Content, Superstate, Props>(
      content: { props in
        self.body(props: props)
      },
      mapProps: map
    )
  }
}
