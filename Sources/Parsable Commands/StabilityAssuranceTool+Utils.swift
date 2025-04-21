//
//  StabilityAssuranceTool+Utils.swift
//  StabilityAssuranceTool
//
//  Created by Andrii Sulimenko on 2025-01-09.
//

import Foundation
import ArgumentParser

// MARK: Test Parsable Command
extension StabilityAssuranceTool {
    /// Test command to demonstrate SPM tool functionality.
    struct TestCommand: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "test",
            abstract: "Test command to show an example of SPM tool function call."
        )
        
        // MARK: - Command Options
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        mutating func run() throws {
            let report = "Woo, test command is working!"
            options.output.writeReport(report)
        }
    }
}

// MARK: Show Data Collected Command
extension StabilityAssuranceTool {
    /// Command to show collected data for the specified filepath.
    struct ShowCollectedDataCommand: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "showData",
            abstract: "Show collected data for the filepath."
        )
        
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        mutating func run() throws {
            guard let path = options.inputFile else {
                throw StabilityAssuranceToolError.missingAttributeArgument("Input filepath")
            }
            var report = "Collecting data for \(path)..."
            
            var visitorClasses: [ClassInfo] = []
            
            if StabilityAssuranceTool().isDirectory(at: path) {
                visitorClasses = try StabilityAssuranceTool().readDirectory(at: path)
            } else {
                visitorClasses = try StabilityAssuranceTool().readFile(at: path)
            }
            
            report.append("\n")
            report.append("Found \(visitorClasses.count) classes")
            
            for visitorViewedClass in visitorClasses {
                report.append("\n")
                report.append(visitorViewedClass.description)
            }
            
            options.output.writeReport(report)
        }
    }
}

// MARK: Evaluate Product Command
extension StabilityAssuranceTool {
    /// Command to evaluate stability of the source code for the specified filepath.
    struct StabilityAssuranceEvaluationCommand: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "evaluate",
            abstract: "Evaluate stbility of the source code for the filepath.",
            subcommands: [
                RFC.self,
                WMC.self,
                NOC.self,
                LOCM.self,
                LinesCounter.self,
                StabilityAssuranceCheck.self
            ],
            defaultSubcommand: StabilityAssuranceCheck.self
        )
    }
}
