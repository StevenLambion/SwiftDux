import Foundation
import SwiftDux
import SwiftUI

struct TodoItemState: IdentifiableState, Hashable, Identifiable {
  var id: String
  var text: String
}
