import Foundation
import Combine

/// Default printer for the `PrintActionMiddleware<_>`
public func defaultActionPrinter(_ actionDiscription: String) {
  print(actionDiscription)
}

/// Prints the details of the latest reducing action.
/// - Parameter printer: A custom printer to send the action discription to. Defaults to print().
public func PrintActionMiddleware<State> (printer: @escaping (String)->() = defaultActionPrinter) -> Middleware<State> {
  { store in { action in
    printer(String(describing: action))
    store.next(action)
  }}
}
