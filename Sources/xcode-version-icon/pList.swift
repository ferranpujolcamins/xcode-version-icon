import Foundation
import ArgumentParser

func xcodeVersion(pListPath: String) throws -> String {
    let pList = try readPlist(at: pListPath)
    guard let version = pList["CFBundleShortVersionString"] as? String else {
        throw ExitCode.failure
    }
    return version
}

func readPlist(at path: String) throws -> [String: Any] {
    var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
    guard let plistXML = FileManager.default.contents(atPath: path) else {
        throw ExitCode.failure
    }
    return try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as! [String: Any]
}
