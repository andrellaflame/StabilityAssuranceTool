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

extension StabilityAssuranceTool {
    struct Options: ParsableArguments {
        @Flag(name: .long, help: "Show extra logging for debugging purposes")
        private var verbose = false

        @Argument(help: "The filepath for data collection.")
        var filepath: String
    }
}

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

extension StabilityAssuranceTool {
    struct ShowCollectedData: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "showData",
            abstract: "Show collected data for the filepath."
        )
        
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        mutating func run() throws {
            
            let filePath = options.filepath
            guard FileManager.default.fileExists(atPath: filePath) else {
                print("File doesn't exist at path: \(filePath)")
                return
            }
            
            guard let file = try? String(contentsOfFile: filePath) else {
                print("File at path isn't readable: \(filePath)")
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

