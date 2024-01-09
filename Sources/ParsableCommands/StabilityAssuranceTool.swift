// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser

@main
struct StabilityAssuranceTool: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A stability assurance tool to provide a quality check for Swift projects",
        subcommands: [
            CollectedData.self,
            StabilityAssuranceMark.self,
            TestCommand.self
        ],
        defaultSubcommand: TestCommand.self
    )
    
    private func countVisitClasses(in file: String) -> [ClassInfo] {
        let sourceFile = Parser.parse(source: file)
        
        let analyzer = CodeAnalyzer(viewMode: .sourceAccurate)
        analyzer.walk(sourceFile)
        
        return analyzer.classStack
    }
    
    // MARK: isDerectory inspection function
    // Function isDirectory inspects whether the path provided is a directory pathname or not
    private func isDirectory(at path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
    
    // MARK: Read directory at @directoryPath
    private func readDirectory(at directoryPath: String) throws -> [ClassInfo] {
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
    private func readFile(at filePath: String) throws -> [ClassInfo] {
        guard let file = try? String(contentsOfFile: filePath) else {
            print("File isn't readable at: \(filePath)")
            return []
        }
        
        let visitorClasses = countVisitClasses(in: file)
        return visitorClasses
    }
}

// MARK: ParsableArguments
extension StabilityAssuranceTool {
    struct Options: ParsableArguments {
        @Flag(name: .long, help: "Show extra logging for debugging purposes")
        private var verbose = false

        @Argument(help: "The filepath for data collection.")
        var filepath: String
    }
}

// MARK: Test Parsable Command
extension StabilityAssuranceTool {
    struct TestCommand: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "test",
            abstract: "Test command to show an example of SPM tool function call."
        )
        
        mutating func run() throws {
            print("Woo, test command is working!")
        }
    }
}

// MARK: Show Data Collected Command
extension StabilityAssuranceTool {
    struct CollectedData: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "showData",
            abstract: "Show collected data for the filepath."
        )
        
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        mutating func run() throws {
            let path = options.filepath
            print("Collected data for \(path)")
            
            var visitorClasses: [ClassInfo] = []
            
            if StabilityAssuranceTool().isDirectory(at: path) {
                visitorClasses = try StabilityAssuranceTool().readDirectory(at: path)
            } else {
                visitorClasses = try StabilityAssuranceTool().readFile(at: path)
            }
            
            print("Found classes count: \(visitorClasses.count)")
            
            for visitorViewedClass in visitorClasses {
                let result = visitorViewedClass.description
                print(result)
            }
        }
    }
}

// MARK: Evaluate Product Command
extension StabilityAssuranceTool {
    struct StabilityAssuranceMark: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "evaluate",
            abstract: "Evaluate stbility of the source code for the filepath.",
            subcommands: [
                RFC.self,
                WMC.self,
                NOC.self
            ]
        )
    }
} 
