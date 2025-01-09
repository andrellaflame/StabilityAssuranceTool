// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser

/// Main entry point for the Stability Assurance Tool.
@main
struct StabilityAssuranceTool: ParsableCommand {
    // MARK: SPM tool configuration
    static let configuration = CommandConfiguration(
        abstract: "A stability assurance tool to provide a quality check for Swift projects",
        subcommands: [
            ShowCollectedDataCommand.self,
            StabilityAssuranceEvaluationCommand.self,
            TestCommand.self
        ],
        defaultSubcommand: TestCommand.self
    )
    
    // MARK: SPM tool private function
    /// Count the visited classes in a Swift file
    /// - Parameter file: `String` filePath value for the product's Swift file
    /// - Returns: An array of `ClassInfo` representing the visited classes
    private func countVisitClasses(fileContent: String, filePath: String) -> [ClassInfo] {
        let sourceFile = Parser.parse(source: fileContent)
        
        let analyzer = CodeAnalyzer(sourceFile: sourceFile, filePath: filePath, viewMode: .sourceAccurate)
        analyzer.walk(sourceFile)
        
        return analyzer.classStack
    }
    
    // MARK: isDerectory inspection function
    /// Function isDirectory inspects whether the path provided is a directory pathname or not
    /// - Parameter path: The path to check.
    /// - Returns: `true` if the path is a directory, otherwise `false`.
    func isDirectory(at path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
    
    // MARK: Read directory at @directoryPath
    /// Read Swift files from the specified directory.
    /// - Parameter directoryPath: The path of the directory to read.
    /// - Throws: If reading directory contents fails.
    /// - Returns: An array of `ClassInfo` representing the classes found.
    func readDirectory(at directoryPath: String) throws -> [ClassInfo] {
        guard let enumerator = FileManager.default.enumerator(atPath: directoryPath) else {
            print("Failed to enumerate the directory.")
            return []
        }
        
        var visitorClasses: [ClassInfo] = []
        
        for case let file as String in enumerator {
            if file.hasSuffix(".swift") {
                let filePath = (directoryPath as NSString).appendingPathComponent(file)
                let retrievedClasses = try readFile(at: filePath)
                visitorClasses.append(contentsOf: retrievedClasses)
            }
        }
        
        return visitorClasses
    }
    
    // MARK: Read file at @filePath
    /// Read Swift file from the specified file path.
    /// - Parameter filePath: The path of the Swift file.
    /// - Throws: If reading file content fails.
    /// - Returns: An array of `ClassInfo` representing the classes found.
    func readFile(at filePath: String) throws -> [ClassInfo] {
        let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
        return countVisitClasses(fileContent: fileContent, filePath: filePath)
    }
}
