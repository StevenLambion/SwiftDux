import Foundation
import SwiftDux

/// Default printer for the `PrintActionMiddleware<_>`
public func defaultActionPrinter(_ actionDiscription: String) {
  print(actionDiscription)
}

/// A simple middlware that prints the description of the latest action.
/// - Parameter printer: A custom printer for the action's discription. Defaults to print().
public func PrintActionMiddleware<State>(printer: @escaping (String) -> () = defaultActionPrinter) -> Middleware<State> {
  { store in
    { action in
      defer { store.next(action) }
      printer(String(describing: action))
    }
  }
}
