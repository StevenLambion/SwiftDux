import Dispatch
import SwiftUI

extension View {

  /// Performs an action asynchronously on the main thread when a view appears.
  ///
  /// SwiftUI doesn't update a view if changes are performed in the onAppear method.
  /// This includes changes to the application state from dispatched actions. This method
  /// allows actions to be dispatched when the view appears.
  /// - Parameter perform: The action to run asynchronously
  /// - Returns: The modified view.
  @available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
  public func onAppearAsync(perform: @escaping () -> Void) -> some View {
    onAppear {
      DispatchQueue.main.async(execute: perform)
    }
  }

  /// Performs an action asynchronously on the main thread when a view appears.
  ///
  /// - Parameter perform: The action to run asynchronously
  /// - Returns: The modified view.
  @available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
  public func onDisappearAsync(perform: @escaping () -> Void) -> some View {
    onDisappear {
      DispatchQueue.main.async(execute: perform)
    }
  }

}
