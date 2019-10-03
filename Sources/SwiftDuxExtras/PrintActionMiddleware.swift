import Foundation
import SwiftDux

/// Default printer for the `PrintActionMiddleware<_>`
public func defaultActionPrinter(_ actionDiscription: String) {
  print(actionDiscription)
}

// swift-format-disable: AlwaysUseLowerCamelCase

/// A simple middlware that prints the description of the latest action.
/// - Parameter printer: A custom printer for the action's discription. Defaults to print().
/// - Returns: The middleware
public func PrintActionMiddleware<State>(printer: @escaping (String) -> Void = defaultActionPrinter) -> Middleware<State> {
  { store in
    { action in
      defer { store.next(action) }
      printer(String(describing: action))
    }
  }
}
