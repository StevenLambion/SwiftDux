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
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
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
