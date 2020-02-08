import SwiftUI

/// Provides the mapped props for ConnectableView.
internal struct Connector<Props, Content>: View where Props: Equatable, Content: View {
  @MappedState var props: Props

  var content: (Props) -> Content

  var body: some View {
    content(props)
  }
}

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
    Connector<Props, Content> { props in
      self.body(props: props)
    }.connect(updateWhen: self.updateWhen, mapState: self.map)
  }
}
