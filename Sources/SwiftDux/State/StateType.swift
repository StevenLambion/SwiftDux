import Foundation

/// Marks an object as representing some kind of state for use by the Store class.
///
/// States are expected to be codable so that they can be easily transportable through extermal
/// APIs and across different platforms. Example usage of a codable state include:
///   - Persisting the application's state to automatically restore it later.
///   - Debugging tools that graph out the entire state object.
///   - Sending whole or partial states to other insrtances of the application, and across platforms.
///
/// State should be viewed as immutable. The only mechanism that should mutate a state is a reducer.
/// Because of this, a state object should be a struct by default. The rule of thumb:
///
/// - Struct: The dafault choice to maintain immutable value semantics.
/// - Class: When it needs to manage a large collection type (greater than a 1000 items)
///
/// You can pick between struct and class for each node in your application's state. It doesn't need to be
/// one or the other as long as the rule of immutability is followed.
public typealias StateType = Codable
