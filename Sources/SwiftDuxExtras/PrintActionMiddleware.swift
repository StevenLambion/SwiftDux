import Foundation
import SwiftDux

/// Default printer for the `PrintActionMiddleware<_>`
fileprivate func defaultActionPrinter(_ actionDescription: String) {
  print(actionDescription)
}

/// A simple middlware that prints the description of the latest action.
public final class PrintActionMiddleware<State>: Middleware {
  public var printer: ((String) -> Void) = defaultActionPrinter
  public var filter: (Action) -> Bool = { _ in true }

  /// Initialize a new PrinterActionMiddleware.
  ///
  /// - Parameters:
  ///   - printer: A custom printer for the action's discription. Defaults to print().
  ///   - filter: Filter what actions get printed.
  public init(printer: ((String) -> Void)? = nil, filter: @escaping (Action) -> Bool = { _ in true }) {
    self.printer = printer ?? defaultActionPrinter
    self.filter = filter
  }

  public func run<State>(store: StoreProxy<State>, action: Action) -> Action? {
    if filter(action) {
      printer(String(describing: action))
    }

    return action
  }
}
