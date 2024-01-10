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
            
            let linesCountCommand = "find \(path) \\( -name \"*.m\" -or -name \"*.mm\" -or -name \"*.cpp\" -or -name \"*.swift\" \\) -print0 | xargs -0 wc -l"
            
            let result = executeCommand(command: linesCountCommand)
            
            let lines = result
                .split(separator: " ")
                .map {
                    $0.description.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            
            guard lines.count % 2 == 0 else {
                print("Some of the files can't be accessed by LinesCounter tool option. Check file extension and file access permissions")
                return
            }
            
            var tupledValues: [(Int, String)] = []
            
            for index in stride(from: 0, to: lines.count, by: 2) {
                let touple = (Int(lines[index]) ?? 0, lines[index + 1])
                tupledValues.append(touple)
            }
            
            tupledValues.printTuples { tuple in
                return "    \(tuple.0) lines: \(tuple.1)"
            }
        }
    }
}
