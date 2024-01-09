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
        subcommands: [ShowCollectedData.self, TestCommand.self],
        defaultSubcommand: TestCommand.self
    )
    
    private func countVisitClasses(in file: String) -> [ClassInfo] {
        let sourceFile = Parser.parse(source: file)
        
        let analyzer = CodeAnalyzer(viewMode: .sourceAccurate)
        analyzer.walk(sourceFile)
        
        return analyzer.classStack
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
    struct ShowCollectedData: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "showData",
            abstract: "Show collected data for the filepath."
        )
        
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        mutating func run() throws {
            let path = options.filepath
            
            if isDirectory(at: path) {
                try readDirectory(at: path)
            } else {
                try readFile(at: path)
            }
        }
        
        private func isDirectory(at path: String) -> Bool {
            var isDirectory: ObjCBool = false
            return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
        }
        
        private func readDirectory(at directoryPath: String) throws {
            guard let enumerator = FileManager.default.enumerator(atPath: directoryPath) else {
                print("Failed to enumerate the directory.")
                return
            }
            
//            let foundFilesCount = enumerator.allObjects.count
//            print("Files found: \(foundFilesCount)")
            
            for case let file as String in enumerator {
                if file.hasSuffix(".swift") {
                    let filePath = (directoryPath as NSString).appendingPathComponent(file)
                    try readFile(at: filePath)
                }
            }
        }
        
        private func readFile(at filePath: String) throws {
            guard let file = try? String(contentsOfFile: filePath) else {
                print("File isn't readable at: \(filePath)")
                return
            }
            
            let visitorClasses = StabilityAssuranceTool().countVisitClasses(in: file)
            
            for visitorViewedClass in visitorClasses {
                let result = visitorViewedClass.description
                print(result)
            }
        }
    }
}

