//
//  LinesCounter.swift
//
//
//  Created by Andrii Sulimenko on 10.01.2024.
//

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser


extension StabilityAssuranceTool.StabilityAssuranceEvaluationCommand {
    /// LOC | Lines of code metric
    ///
    /// This command counts the total number of lines of code in passed directory.
    struct LinesCounter: ParsableCommand {
        
        // MARK: - Configuration
        static var configuration = CommandConfiguration(
            commandName: "countLines",
            abstract: "A tool command to count the number of lines for Swift projects.",
            discussion:
                    """
                    # Counter of the program code lines in passed directory
                    
                    This command counts the total number of lines of code in the passed directory.
                    """
        )
        
        // MARK: - Command Options
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        /// Counts the number of lines in files at the specified path.
        /// - Parameter path: The directory path where files are located.
        /// - Returns: An array of tuples containing the number of lines and the file path.
        func countLines(at path: String) -> [(Int, String)] {
            let linesCountCommand = "find \(path) \\( -name \"*.m\" -or -name \"*.mm\" -or -name \"*.cpp\" -or -name \"*.swift\" \\) -print0 | xargs -0 wc -l"
            
            let result = executeCommand(command: linesCountCommand)
            
            let lines = result
                .components(separatedBy: "\n")
                .map {
                    $0.trimmingCharacters(in: .whitespaces)
                }
                .filter { !$0.isEmpty }
            
            let tupledValues = lines.compactMap { line -> (Int, String)? in
                let components = line.components(separatedBy: .whitespaces)
                
                if components.count >= 2, let numberOfLines = Int(components[0]) {
                    let directory = components.dropFirst().joined(separator: " ")
                    return (numberOfLines, directory)
                }
                
                print("Some of the files can't be accessed by LinesCounter tool option. Check file extension and file access permissions")
                return nil
            }
            
            return tupledValues
        }
        
        private func executeCommand(command: String) -> String {
            let process = Process()
            process.launchPath = "/bin/bash"
            process.arguments = ["-c", command]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.launch()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)
            
            return output ?? ""
        }
        
        // MARK: - Metric run func
        /// Main `ParsableCommand` function for the command execution
        mutating func run() throws {
            guard let path = options.inputFile else {
                throw StabilityAssuranceToolError.missingAttributeArgument("Input filepath")
            }
            
            print("Trying to count lines of code at: \(path)")
            
            let tupledResult = countLines(at: path)
            
            let report: String = tupledResult
                .map { "    \($0.0) lines: \($0.1)\n" }
                .joined()
            
            options.output.writeReport(report)
        }
    }
}
