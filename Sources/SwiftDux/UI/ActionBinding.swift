import Foundation
import SwiftUI

/// Binds a value with an action. Use the `ActionBinder` to create an action binding.
@propertyWrapper
public struct ActionBinding<Value> {

  /// Projects to a regular binding when using the '$' prefix.
  public var projectedValue: Binding<Value>

  /// The current value of the binding.
  @inlinable public var wrappedValue: Value {
    get { projectedValue.wrappedValue }
    set { projectedValue.wrappedValue = newValue }
  }

  @inlinable internal init(value: Value, set: @escaping (Value) -> Void) {
    projectedValue = Binding(get: { value }, set: set)
  }

  /// Returns a regular binding.
  /// - Returns: The binding.
  public func toBinding() -> Binding<Value> {
    projectedValue
  }
}

extension ActionBinding: Equatable where Value: Equatable {

  @inlinable public static func == (lhs: ActionBinding<Value>, rhs: ActionBinding<Value>) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}
