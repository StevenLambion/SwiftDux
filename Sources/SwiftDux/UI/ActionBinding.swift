import Foundation
import SwiftUI

/// Binds a value with an action. Use the `ActionBinder` to create an action binding.
@propertyWrapper
public struct ActionBinding<Value> {

  @usableFromInline
  internal var isEqual: (Value) -> Bool

  /// Projects to a regular binding when using the '$' prefix.
  public var projectedValue: Binding<Value>

  /// The current value of the binding.
  @inlinable public var wrappedValue: Value {
    get { projectedValue.wrappedValue }
    set { projectedValue.wrappedValue = newValue }
  }

  @inlinable internal init(value: Value, isEqual: @escaping (Value) -> Bool, set: @escaping (Value) -> Void) {
    self.isEqual = isEqual
    self.projectedValue = Binding(get: { value }, set: set)
  }

  @inlinable static internal func constant<T>(value: T) -> ActionBinding<T> {
    ActionBinding<T>(value: value, isEqual: { _ in true }, set: { _ in })
  }

  @inlinable static internal func constant<T>(value: T) -> ActionBinding<T> where T: Equatable {
    ActionBinding<T>(value: value, isEqual: { value == $0 }, set: { _ in })
  }

  /// Returns a regular binding.
  /// - Returns: The binding.
  public func toBinding() -> Binding<Value> {
    projectedValue
  }
}

extension ActionBinding: Equatable {

  public static func == (lhs: ActionBinding<Value>, rhs: ActionBinding<Value>) -> Bool {
    lhs.isEqual(rhs.wrappedValue) && rhs.isEqual(lhs.wrappedValue)
  }
}
