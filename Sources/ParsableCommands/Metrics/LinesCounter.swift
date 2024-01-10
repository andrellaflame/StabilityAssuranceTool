//
//  File.swift
//  
//
//  Created by Andrii Sulimenko on 10.01.2024.
//

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser

extension StabilityAssuranceTool.StabilityAssuranceMark {
    struct LinesCounter: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "countLines",
            abstract: "A tool command to count the number of lines for Swift projects.",
            discussion:
                """
                # Counter of th program code lines in passed directory
                
                This command counts the total number of lines of code in passed directory.
                """
        )
        
        @OptionGroup var options: StabilityAssuranceTool.Options
        
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
        
        mutating func run() throws {
            let path = options.filepath
            print("Trying to count lines of code at: \(path)")
            
            let tupledResult = countLines(at: path)
            tupledResult.printTuples { tuple in
                return "    \(tuple.0) lines: \(tuple.1)"
            }
        }
    }
}
