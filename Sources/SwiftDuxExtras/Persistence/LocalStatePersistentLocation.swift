import Foundation
import SwiftDux

fileprivate func getDefaultFileUrl() -> URL {
  if let directoryURL = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
    return directoryURL.appendingPathComponent("appData.json")
  }
  fatalError("Unable to create default file url for StatePersistor")
}

/// The location of application state within the local filesystem.
///
/// By default, it stores the application state inside the Application Support directory.
public struct LocalStatePersistentLocation: StatePersistentLocation {

  /// The file location in the local filesystem.
  public let fileUrl: URL

  /// Initiate a new location with an optional file url.
  /// - Parameter fileUrl: An optional url of the file location.
  public init(fileUrl: URL? = nil) {
    self.fileUrl = fileUrl ?? getDefaultFileUrl()
  }

  /// Save the data to the local filesystem.
  /// - Parameter data: The data to save.
  public func save(_ data: Data) -> Bool {
    do {
      try data.write(to: fileUrl)
      return true
    } catch {
      print("Failed to save state to \(fileUrl)")
      return false
    }
  }

  /// Retrieve the data from the local filesystem.
  public func restore() -> Data? {
    try? Data(contentsOf: fileUrl)
  }

}
