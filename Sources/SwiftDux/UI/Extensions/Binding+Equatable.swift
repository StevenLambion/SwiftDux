import SwiftUI

extension Binding: Equatable where Value: Equatable {

  public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }

}
