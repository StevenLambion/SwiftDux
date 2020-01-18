import Foundation
import SwiftDux

/// Default printer for the `PrintActionMiddleware<_>`
fileprivate func defaultActionPrinter(_ actionDescription: String) {
  print(actionDescription)
}

// swift-format-disable: AlwaysUseLowerCamelCase

/// A simple middlware that prints the description of the latest action.
/// - Parameters:
///   - printer: A custom printer for the action's discription. Defaults to print().
///   - filter: Filter what actions get printed.
/// - Returns: The middleware
public func PrintActionMiddleware<State>(printer: ((String) -> Void)? = nil, filter: @escaping (Action) -> Bool = { _ in true }) -> Middleware<State> {
  let printer = printer ?? defaultActionPrinter
  return { store in
    { action in
      defer { store.next(action) }
      guard filter(action) else { return }
      printer(String(describing: action))
    }
  }
}
