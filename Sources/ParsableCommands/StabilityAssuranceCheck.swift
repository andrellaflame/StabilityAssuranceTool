//
//  StabilityAssuranceCheck.swift
//
//
//  Created by Andrii Sulimenko on 10.01.2024.
//

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser
#if canImport(AppKit)
import AppKit
#endif


extension StabilityAssuranceTool.StabilityAssuranceMark {
    /// Overall product stability mark
    ///
    /// This mark is evaluated using results of all metrics counted together for the project in passed directory. It uses predefined tables of values for particular metrics.
    struct StabilityAssuranceCheck: ParsableCommand {
        
        // MARK: - Configuration
        static var configuration = CommandConfiguration(
            commandName: "stats",
            abstract: "The main stability assurance tool command to evaluate `Overall stability mark` for Swift projects.",
            discussion:
                """
                # Overall stability mark
                
                This mark is evaluated using results of all metrics counted together for the project in passed directory. It uses predefined tables of values for particular metrics.
                """
        )
        
        // MARK: - Command Options
        @OptionGroup var options: StabilityAssuranceTool.Options
        @Option(
            help:
                """
                The output format type for the overall stability report.
                
                --output console | printed console output for generated product stability assurance check.
                
                --output html | auto-generaged HTML page for the product stability assurance check report.
                
                NOTE: In order to save generated product stability assurance report to a file, add output file path after input directory path
                """
        )
        
        var output: OutputFormat = .console
        
        /// Evaluates overall stability of the product at passed data and path
        /// - Parameter path: `String` filePath value for the product
        /// - Parameter data: `ClassInfo` array containing gathered information about each class of the directory
        /// - Parameter type: `OutputFormat` format option for the overall mark output
        /// - Returns: `SATReportWriter` object for stability evaluation report
        private func evaluateProduct(at path: String, for data: [ClassInfo], type: OutputFormat) -> SATReportWriter {
            // MARK: Evaluating metrics
            let evaluatedWMC = WMC().evaluateWMC(for: data, type: .custom)
            let evaluatedRFC = RFC().evaluateRFC(for: evaluatedWMC)
            let evaluatedResult = NOC().evaluateNOC(for: evaluatedRFC)
            
            var evaluatedMetrics: [(String, any Numeric, SATMark)] = []
            var scale: ProjectSize = .unowned
            
            // Allowed values for metrics that are directly dependant on the scale of the product
            var allowedValueNOCPerClass: Double = 0
            
            // Total WMC
            let totalWMC = evaluatedResult.reduce(0) { $0 + $1.WMC.0 }
            let averageWMC: Double = Double(totalWMC) / Double(evaluatedWMC.count)
            let averageRoundedValueWMC: Double = Double(round(averageWMC * 100) / 100)
            var classesWithHighWMC: Double = 0
            
            // Total RFC
            let totalRFC = evaluatedResult.reduce(0) { $0 + $1.RFC.0 }
            let averageRFC = Double(totalRFC) / Double(evaluatedResult.count)
            let averageRoundedValueRFC: Double = Double(round(averageRFC * 100) / 100)
            
            // Total NOC
            let averageNOC: Double = evaluatedResult.reduce(0.0) {
                $0 + Double($1.NOC.0) / Double(evaluatedResult.count)
            }
            let averageRoundedValueNOC: Double = Double(round(averageNOC * 100) / 100)
            
            // Total LOC
            let linesCount = LinesCounter().countLines(at: path).last?.0 ?? 0
            evaluatedMetrics.append(("LOC", linesCount, .unowned))
            
            switch data.count {
            case let value where value < 50:
                scale = .small
                allowedValueNOCPerClass = Double(data.count) * 0.1
            case let value where value < 200:
                scale = .medium
                allowedValueNOCPerClass = Double(data.count) * 0.3
            default:
                scale = .large
                allowedValueNOCPerClass = Double(data.count) * 0.5
            }
            
            
            for classInstance in evaluatedResult {
                switch Double(classInstance.NOC.0) {
                case let NOCvalue where NOCvalue < allowedValueNOCPerClass:
                    classInstance.NOC.1 = .good
                case let NOCvalue where NOCvalue < allowedValueNOCPerClass + allowedValueNOCPerClass * 0.1:
                    classInstance.NOC.1 = .accepted
                default:
                    classInstance.NOC.1 = .poor
                }
                
                switch Double(classInstance.WMC.0) {
                case let WMCvalue where WMCvalue <= averageWMC:
                    classInstance.WMC.1 = .good
                case let WMCvalue where WMCvalue < averageWMC + averageWMC * 0.1:
                    classInstance.WMC.1 = .accepted
                    classesWithHighWMC += 1
                default:
                    classInstance.WMC.1 = .poor
                    classesWithHighWMC += 1
                }
                
                switch Double(classInstance.RFC.0) {
                case let RFCvalue where RFCvalue < 50:
                    classInstance.RFC.1 = .good
                case let RFCvalue where RFCvalue < 100:
                    classInstance.RFC.1 = .accepted
                default:
                    classInstance.RFC.1 = .poor
                }
            }
            
            // Marking metrics
            let WMCmark: SATMark =
            classesWithHighWMC <= Double(evaluatedResult.count) * 0.1 ? .good:
            classesWithHighWMC <= Double(evaluatedResult.count) * 0.3 ? .accepted:
                .poor
            
            let NOCmark: SATMark =
            averageNOC < allowedValueNOCPerClass ? .good:
            averageNOC < allowedValueNOCPerClass + allowedValueNOCPerClass * 0.1 ? .accepted:
                .poor
            
            let RFCmark: SATMark =
            averageRFC < 50 ? .good:
            averageRFC < 100 ? .accepted:
                .poor
            
            // Appending metrics results
            evaluatedMetrics.append(("WMC", averageRoundedValueWMC, WMCmark))
            evaluatedMetrics.append(("NOC", averageRoundedValueNOC, NOCmark))
            evaluatedMetrics.append(("RFC", averageRoundedValueRFC, RFCmark))
            
            return SATReportWriter(
                projectDirectory: path,
                projectScale: scale,
                evaluatedMetrics: evaluatedMetrics,
                evaluatedData: evaluatedResult,
                outputFormat: output
            )
        }
        
        // MARK: - Metric run func
        /// Main `ParsableCommand` function for the command execution
        mutating func run() throws {
            let path = options.inputFile
            print("Trying to apply metrics to evaluate stability for: \(path)")
            
            var visitorClasses: [ClassInfo] = []
            
            if StabilityAssuranceTool().isDirectory(at: path) {
                visitorClasses = try StabilityAssuranceTool().readDirectory(at: path)
            } else {
                visitorClasses = try StabilityAssuranceTool().readFile(at: path)
            }
            
            let report = evaluateProduct(
                at: path,
                for: visitorClasses,
                type: output
            ).report
            
            switch output {
            case .console:
                print(report)
            case .html:
                let tempDirectory = FileManager.default.temporaryDirectory
                let htmlFilePath = tempDirectory.appendingPathComponent("report.html")

                do {
                    try report.write(to: htmlFilePath, atomically: true, encoding: .utf8)
                } catch {
                    print("Error writing HTML file: \(error)")
                }

                // Step 3: Open the HTML file in the default web browser
#if canImport(AppKit)
                if NSWorkspace.shared.open(htmlFilePath) {
                    print("Report is opened in HTML file successfully.")
                } else {
                    print("Failed to open HTML file.")
                }
#else
                print("NSWorkspace is not available.")
#endif
            case .file(let filePath):
                do {
                    try report.write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
                    print("Report written to file at \(filePath).")
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
    }
}
