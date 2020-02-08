import Foundation
import SwiftUI

/// Binds a value with an action. Use the `ActionBinder` to create an action binding.
@propertyWrapper
public struct ActionBinding<Value> {
  private var valueBinding: Binding<Value>
  
  /// The current value of the binding.
  public var wrappedValue: Value {
    valueBinding.wrappedValue
  }
  
  /// Projects to a regular binding when using the '$' prefix.
  public var projectedValue: Binding<Value> {
    toBinding()
  }
  
  internal init(value: Value, set: @escaping (Value) -> ()) {
    valueBinding = Binding(get: { value }, set: set)
  }
  
  /// Returns a regular binding.
  /// - Returns: The binding.
  public func toBinding() -> Binding<Value> {
    valueBinding
  }
}

extension ActionBinding: Equatable where Value: Equatable {
  
  public static func == (lhs: ActionBinding<Value>, rhs: ActionBinding<Value>) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}
