import SwiftUI

/// A view that connects to the application state.
public protocol ConnectableView: View, Connectable {
  associatedtype Content: View

  /// Return the body of the view using the provided props object.
  /// - Parameter props: A mapping of the application to the props used by the view.
  /// - Returns: The connected view.
  func body(props: Props) -> Content
}

extension ConnectableView {

  public var body: some View {
    Connector<Content, Superstate, Props>(
      content: { props in
        self.body(props: props)
      },
      filter: updateWhen,
      mapProps: map
    )
  }
}
