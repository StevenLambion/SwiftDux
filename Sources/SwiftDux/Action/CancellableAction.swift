import Combine
import Foundation

/// An action that can return a cancellable object. Don't use this protocol directly.
/// Instead, use an ActionPlan. This allows action plans with a publisher to be explicitly cancelled by
/// their source dispatcher rather than internally or by the store.
public protocol CancellableAction: Action {

  /// Send an action that returns a cancellabe object.
  ///
  /// This is useful for action plans that return a publisher that require a cancellable step. For example, a web request
  /// that should be cancelled if the user navigates away from the relevant view.
  ///
  /// ```
  /// struct MyView: View {
  ///
  ///   @MappedDispatch() private var dispatch
  ///
  ///   @State private var username: String = ""
  ///   @State private var password: String = ""
  ///
  ///   @State private var signUpCancellable: AnyCancellable? = nil
  ///
  ///   var body: some View {
  ///     Group {
  ///       /// ...signup form
  ///       Button(action: self.signUp) { Text("Sign Up") }
  ///     }
  ///     .onDisappear { self.signUpCancellable?.cancel() }
  ///   }
  ///
  ///   func signUp() {
  ///     signUpCancellable = signUpActionPlan(username: username, password: password).sendAsCancellable(dispatch)
  ///   }
  ///
  /// }
  /// ```
  ///
  /// - Parameter send: The send function that dispatches an action.
  /// - Returns: AnyCancellable to cancel the action plan.
  func sendAsCancellable(_ send: SendAction) -> Cancellable

}
