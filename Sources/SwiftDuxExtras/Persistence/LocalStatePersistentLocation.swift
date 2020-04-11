import Foundation
import SwiftDux

fileprivate func getDefaultFileUrl() -> URL {
  guard var directoryURL = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
    fatalError("Unable to create default file url for StatePersistor")
  }
  /// Add project identifier if it exists.
  if let identifier = Bundle.main.bundleIdentifier {
    directoryURL = directoryURL.appendingPathComponent(identifier)
  }
  do {
    if !FileManager.default.fileExists(atPath: directoryURL.path) {
      try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }
  } catch {
    fatalError("Unable to create directory at \(directoryURL.path)")
  }
  return directoryURL.appendingPathComponent("state")
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
  /// - Returns: True if the save was successful.
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
  /// - Returns: The data if successful.
  public func restore() -> Data? {
    try? Data(contentsOf: fileUrl)
  }
}
