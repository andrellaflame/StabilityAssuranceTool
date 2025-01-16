//
//  StabilityAssuranceTool+Evaluation.swift
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


extension StabilityAssuranceTool.StabilityAssuranceEvaluationCommand {
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
        
        /// Calculate average value of each metric
        private func calculateAverage(_ values: [Int]) -> Double {
            Double(values.reduce(0, +)) / Double(values.count)
        }
        
        /// Evaluates individual metrics according to the thresholds boundaries
        private func evaluateMetric(value: Double, thresholds: (good: Double, accepted: Double)) -> SATMark {
            if value <= thresholds.good {
                return .good
            } else if value <= thresholds.accepted {
                return .accepted
            }
            return .poor
        }
        
        /// Evaluates overall stability of the product at passed data and path
        /// - Parameter path: `String` filePath value for the product
        /// - Parameter data: `ClassInfo` array containing gathered information about each class of the directory
        /// - Parameter type: `OutputFormat` format option for the overall mark output
        /// - Returns: `SATReportWriter` object for stability evaluation report
        private func evaluateProduct(at path: String, for data: [ClassInfo], type: OutputFormat) throws -> SATReportWriter {
            // MARK: Evaluating metrics
            let evaluatedWMC = WMC().evaluateWMC(for: data, type: .custom)
            let evaluatedRFC = RFC().evaluateRFC(for: evaluatedWMC)
            let evaluatedResult = NOC().evaluateNOC(for: evaluatedRFC)
            
            /// Total WMC
            let averageWMC = calculateAverage(evaluatedResult.map { $0.WMC.0 })
            var classesWithHighWMC: Double = 0
            /// Total RFC
            let averageRFC = calculateAverage(evaluatedResult.map { $0.RFC.0 })
            /// Total NOC
            let averageNOC = calculateAverage(evaluatedResult.map { $0.NOC.0 })
            /// Total LOC
            let linesCount = LinesCounter().countLines(at: path).last?.0 ?? 0
            /// Project scale
            let scale = ProjectSize.determineScale(for: data.count)
            
            /// Allowed NOC per class
            ///
            /// Allowed values for metrics that are directly dependant on the scale of the product
            let allowedValueNOCPerClass: Double = {
                return switch scale {
                case .small:
                    Double(data.count) * 0.1
                case .medium:
                    Double(data.count) * 0.3
                case .large:
                    Double(data.count) * 0.5
                default:
                    0.0
                }
            }()
            
            
            // Evaluated metrics per class
            var evaluatedMetrics: [(String, any Numeric, SATMark)] = []
            evaluatedMetrics.append(("LOC", linesCount, .unowned))
            
            // Thresholds for each metric
            let WMCThresholds = (good: averageWMC, accepted: averageWMC * 1.1)
            let RFCThresholds = (good: 50.0, accepted: 100.0)
            let NOCThresholds = (good: allowedValueNOCPerClass, accepted: allowedValueNOCPerClass * 1.1)
            
            for classInstance in evaluatedResult {
                /// Evaluate NOC
                classInstance.NOC.1 = evaluateMetric(value: Double(classInstance.NOC.0), thresholds: NOCThresholds)
                /// Evaluate WMC
                classInstance.WMC.1 = evaluateMetric(value: Double(classInstance.WMC.0), thresholds: WMCThresholds)
                /// Evaluate RFC
                classInstance.RFC.1 = evaluateMetric(value: Double(classInstance.RFC.0), thresholds: RFCThresholds)
                // Increment high WMC classes for overall mark
                if classInstance.WMC.1 == .poor {
                    classesWithHighWMC += 1
                }
                
                // Add editor messages for script-based execution
                if case .file(_) = options.output {
                    // NOC Message
                    if classInstance.NOC.1 == .accepted || classInstance.NOC.1 == .poor {
                        let NOCMessage = SATReportWriter.formatIssueMessage(classInstance, message: classInstance.NOC.1 == .accepted ? NOC.acceptedMessage : NOC.poorMessage)
                        print(NOCMessage)
                    }
                    // WMC Message
                    if classInstance.WMC.1 == .accepted || classInstance.WMC.1 == .poor {
                        let WMCMessage = SATReportWriter.formatIssueMessage(classInstance, message: classInstance.WMC.1 == .accepted ? WMC.acceptedMessage : WMC.poorMessage)
                        print(WMCMessage)
                    }
                    // RFC Message
                    if classInstance.RFC.1 == .accepted || classInstance.RFC.1 == .poor {
                        let RFCMessage = SATReportWriter.formatIssueMessage(classInstance, message: classInstance.RFC.1 == .accepted ? RFC.acceptedMessage : RFC.poorMessage)
                        print(RFCMessage)
                    }
                }
            }
            
            // Marking metrics
            let WMCmark: SATMark = classesWithHighWMC <= Double(evaluatedResult.count) * 0.1 ? .good : classesWithHighWMC <= Double(evaluatedResult.count) * 0.3 ? .accepted : .poor
            let NOCmark: SATMark = averageNOC < allowedValueNOCPerClass ? .good : averageNOC < allowedValueNOCPerClass + allowedValueNOCPerClass * 0.1 ? .accepted : .poor
            let RFCmark: SATMark = averageRFC < 50 ? .good : averageRFC < 100 ? .accepted : .poor
            
            // Appending metrics results
            evaluatedMetrics.append(("WMC", averageWMC, WMCmark))
            evaluatedMetrics.append(("NOC", averageNOC, NOCmark))
            evaluatedMetrics.append(("RFC", averageRFC, RFCmark))
            
            print("Evaluation completed for: \(path)")
            
            return SATReportWriter(
                projectDirectory: path,
                projectScale: scale,
                evaluatedMetrics: evaluatedMetrics,
                evaluatedData: evaluatedResult,
                outputFormat: options.output
            )
        }
        
        // MARK: - Metric run func
        /// Main `ParsableCommand` function for the command execution
        mutating func run() throws {
            guard let path = options.inputFile else {
                throw StabilityAssuranceToolError.missingAttributeArgument("Input filepath")
            }
            
            if let configurationPath = options.config {
                print("Loading configuration from \(configurationPath)...")
                if let config = StabilityAssuranceTool.loadConfiguration(from: configurationPath) {
                    options.output = config.output
                } else {
                    throw StabilityAssuranceToolError.invalidConfiguration("Failed to load configuration file (\(configurationPath))")
                }
            }
            
            print("Attempting to apply metrics to evaluate stability for: \(path)...")
            
            var visitorClasses: [ClassInfo] = []
            
            if StabilityAssuranceTool().isDirectory(at: path) {
                visitorClasses = try StabilityAssuranceTool().readDirectory(at: path)
            } else {
                visitorClasses = try StabilityAssuranceTool().readFile(at: path)
            }
            
            let report = try evaluateProduct(
                at: path,
                for: visitorClasses,
                type: options.output
            ).report
            
            options.output.writeReport(report)
        }
    }
}
