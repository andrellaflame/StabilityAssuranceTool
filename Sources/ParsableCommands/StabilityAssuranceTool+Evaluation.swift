//
//  StabilityAssuranceTool+Evaluation.swift
//
//
//  Created by Andrii Sulimenko on 10.01.2024.
//

import Foundation
import ArgumentParser
#if canImport(AppKit)
import AppKit
#endif


extension StabilityAssuranceTool.StabilityAssuranceEvaluationCommand {
    /// Overall product stability mark
    ///
    /// This mark is evaluated using results of all metrics counted together for the project in passed directory. It uses predefined tables of values for particular metrics.
    struct StabilityAssuranceCheck: ParsableCommand {
        // MARK: - Stored Properties
        private var totalWarnings: Int = 0
        
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
        private func evaluateMetric(value: Double, thresholds: Thresholds) -> SATMark {
            if value <= thresholds.good {
                return .good
            } else if value <= thresholds.accepted {
                return .accepted
            }
            return .poor
        }
        
        /// Handles metrics severity response
        private mutating func handleMetricEvaluation(
            classInstance: ClassInfo,
            message: String,
            severity: MetricSeverity?
        ) {
            let formattedMessage = SATReportWriter.formatIssueMessage(
                classInstance,
                message: message,
                severity: severity ?? .warning
            )
            
            print(formattedMessage)
            
            switch severity {
            case .warning:
                totalWarnings += 1
            case .error: // Early exit
                StabilityAssuranceTool.StabilityAssuranceEvaluationCommand.StabilityAssuranceCheck.exit(withError: StabilityAssuranceToolError.metricSeverity())
            default: // Empty case for switch exhaustiveness
                break
            }
        }
        
        /// Evaluates overall stability of the product at passed data and path
        /// - Parameter path: `String` filePath value for the product
        /// - Parameter data: `ClassInfo` array containing gathered information about each class of the directory
        /// - Parameter metrics: Enabled metrics for product evaluation. Defaults to all metrics use
        /// - Parameter thresholds: Custom thresholds for the enabled metrics in product evaluation. Defaults to predefined metrics logic
        /// - Returns: `SATReportWriter` object for stability evaluation report
        private mutating func evaluateProduct(
            at path: String,
            for data: [ClassInfo],
            configuration: SATConfiguration
        ) throws -> SATReportWriter {
            /// Default metrics if none are provided
            let metricsToEvaluate = configuration.enabledMetrics.isEmpty ? ["WMC", "RFC", "NOC", "LOCM"] : configuration.enabledMetrics
            
            // MARK: Evaluating metrics based on provided/default configuration
            /// Evaluated metric results
            var evaluatedResult = [ClassInfo]()
            /// WMC metric calculation
            if metricsToEvaluate.contains("WMC") {
                evaluatedResult = WMC().evaluateWMC(for: data, type: .custom)
            }
            /// RFC metric calculation
            if metricsToEvaluate.contains("RFC") {
                evaluatedResult = RFC().evaluateRFC(for: evaluatedResult.isEmpty ? data : evaluatedResult)
            }
            /// NOC metric calculation
            if metricsToEvaluate.contains("NOC") {
                evaluatedResult = NOC().evaluateNOC(for: evaluatedResult.isEmpty ? data : evaluatedResult)
            }
            /// LOCM metric calculation
            if metricsToEvaluate.contains("LOCM") {
                evaluatedResult = LOCM().evaluateLOCM(for: evaluatedResult.isEmpty ? data : evaluatedResult)
            }
            
            /// Total WMC
            let averageWMC = calculateAverage(evaluatedResult.map { $0.WMC.0 })
            var classesWithHighWMC: Double = 0
            /// Total RFC
            let averageRFC = calculateAverage(evaluatedResult.map { $0.RFC.0 })
            /// Total NOC
            let averageNOC = calculateAverage(evaluatedResult.map { $0.NOC.0 })
            /// Total LOCM
            let averageLOCM = calculateAverage(evaluatedResult.map { $0.LOCM.0 })
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
            
            
            /// Evaluated metrics per class
            var evaluatedMetrics: [(String, Double, SATMark)] = []
            evaluatedMetrics.append(("LOC", Double(linesCount), .unowned))
            
            /// Thresholds for each metric
            let WMCThresholds = configuration.metricsConfiguration["WMC"]?.thresholds ?? Thresholds(good: averageWMC, accepted: averageWMC * 1.1)
            let RFCThresholds = configuration.metricsConfiguration["RFC"]?.thresholds ?? Thresholds(good: 50.0, accepted: 100.0)
            let NOCThresholds = configuration.metricsConfiguration["NOC"]?.thresholds ?? Thresholds(good: allowedValueNOCPerClass, accepted: allowedValueNOCPerClass * 1.1)
            let LOCMThresholds = configuration.metricsConfiguration["LOCM"]?.thresholds ?? Thresholds(good: 3.0, accepted: 9.0)
            
            /// Thresholds for each metric
            let WMCSeverity = configuration.metricsConfiguration["WMC"]?.severity
            let RFCSeverity = configuration.metricsConfiguration["RFC"]?.severity
            let NOCSeverity = configuration.metricsConfiguration["NOC"]?.severity
            let LOCMSeverity = configuration.metricsConfiguration["LOCM"]?.severity
            
            for classInstance in evaluatedResult {
                /// Evaluate NOC
                classInstance.NOC.1 = evaluateMetric(value: Double(classInstance.NOC.0), thresholds: NOCThresholds)
                /// Evaluate WMC
                classInstance.WMC.1 = evaluateMetric(value: Double(classInstance.WMC.0), thresholds: WMCThresholds)
                /// Evaluate RFC
                classInstance.RFC.1 = evaluateMetric(value: Double(classInstance.RFC.0), thresholds: RFCThresholds)
                /// Evaluate LOCM
                classInstance.LOCM.1 = evaluateMetric(value: Double(classInstance.LOCM.0), thresholds: LOCMThresholds)
                // Increment high WMC classes for overall mark
                if classInstance.WMC.1 == .poor {
                    classesWithHighWMC += 1
                }
                
                // Add editor messages for script-based execution
                if case .file(_) = options.output {
                    // NOC Message
                    if metricsToEvaluate.contains("NOC") {
                        if classInstance.NOC.1 == .poor {
                            handleMetricEvaluation(
                                classInstance: classInstance,
                                message: NOC.poorMessage,
                                severity: NOCSeverity?.poor
                            )
                        } else if classInstance.NOC.1 == .accepted {
                            handleMetricEvaluation(
                                classInstance: classInstance,
                                message: NOC.acceptedMessage,
                                severity: NOCSeverity?.acceptable
                            )
                        }
                    }
                    
                    // WMC Message
                    if metricsToEvaluate.contains("WMC") {
                        if classInstance.WMC.1 == .poor {
                            handleMetricEvaluation(
                                classInstance: classInstance,
                                message: WMC.poorMessage,
                                severity: WMCSeverity?.poor
                            )
                        } else if classInstance.WMC.1 == .accepted {
                            handleMetricEvaluation(
                                classInstance: classInstance,
                                message: WMC.acceptedMessage,
                                severity: WMCSeverity?.acceptable
                            )
                        }
                    }
                    
                    // RFC Message
                    if metricsToEvaluate.contains("RFC") {
                        if classInstance.RFC.1 == .poor {
                            handleMetricEvaluation(
                                classInstance: classInstance,
                                message: RFC.poorMessage,
                                severity: RFCSeverity?.poor
                            )
                        } else if classInstance.RFC.1 == .accepted {
                            handleMetricEvaluation(
                                classInstance: classInstance,
                                message: RFC.acceptedMessage,
                                severity: RFCSeverity?.acceptable
                            )
                        }
                    }
                    
                    // LOCM Message
                    if metricsToEvaluate.contains("LOCM") {
                        if classInstance.LOCM.1 == .poor {
                            handleMetricEvaluation(
                                classInstance: classInstance,
                                message: LOCM.poorMessage,
                                severity: LOCMSeverity?.poor
                            )
                        } else if classInstance.LOCM.1 == .accepted {
                            handleMetricEvaluation(
                                classInstance: classInstance,
                                message: LOCM.acceptedMessage,
                                severity: LOCMSeverity?.acceptable
                            )
                        }
                    }
                }
            }
            
            // Marking metrics
            let WMCmark: SATMark = classesWithHighWMC <= Double(evaluatedResult.count) * 0.1 ? .good : classesWithHighWMC <= Double(evaluatedResult.count) * 0.3 ? .accepted : .poor
            let NOCmark: SATMark = averageNOC < allowedValueNOCPerClass ? .good : averageNOC < allowedValueNOCPerClass + allowedValueNOCPerClass * 0.1 ? .accepted : .poor
            let RFCmark: SATMark = averageRFC < 50 ? .good : averageRFC < 100 ? .accepted : .poor
            let LOCMmark: SATMark = averageLOCM < 3 ? .good : averageLOCM < 9 ? .accepted : .poor
            
            // Appending metrics results
            if metricsToEvaluate.contains("WMC") {
                evaluatedMetrics.append(("WMC", averageWMC, WMCmark))
            }
            if metricsToEvaluate.contains("NOC") {
                evaluatedMetrics.append(("NOC", averageNOC, NOCmark))
            }
            if metricsToEvaluate.contains("RFC") {
                evaluatedMetrics.append(("RFC", averageRFC, RFCmark))
            }
            if metricsToEvaluate.contains("LOCM") {
                evaluatedMetrics.append(("LOCM", averageLOCM, LOCMmark))
            }
            
            print("Evaluation completed for: \(path)")
            
            if let maxAllowedWarnings = configuration.maxAllowedWarnings, totalWarnings >= maxAllowedWarnings {
                let message = "Received evaluation result exceeded configured max allowed warnings limit"
                let formattedMessage = SATReportWriter.formatIssueMessage(message: message, severity: .error)
                
                print(formattedMessage)
                
                StabilityAssuranceTool.StabilityAssuranceEvaluationCommand.StabilityAssuranceCheck.exit(withError: StabilityAssuranceToolError.metricSeverity(message))
            }
            
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
                StabilityAssuranceTool.StabilityAssuranceEvaluationCommand.StabilityAssuranceCheck.exit(withError: StabilityAssuranceToolError.missingAttributeArgument("Input filepath"))
            }
            
            /// Load configuration if available, otherwise use default values
            let configuration: SATConfiguration
            if let configurationPath = options.config {
                print("Loading configuration from \(configurationPath) ...")
                guard let loadedConfiguration = StabilityAssuranceTool.loadConfiguration(from: configurationPath) else {
                    StabilityAssuranceTool.StabilityAssuranceEvaluationCommand.StabilityAssuranceCheck.exit(
                        withError: StabilityAssuranceToolError.invalidConfiguration("Failed to load configuration file (\(configurationPath))")
                    )
                }
                configuration = loadedConfiguration
            } else {
                configuration = SATConfiguration.default
            }
            
            /// Assign output configuration
            options.output = OutputFormat(argument: configuration.output)
            
            print("Attempting to apply metrics to evaluate stability for: \(path) ...")
            
            var visitorClasses: [ClassInfo] = []
            
            if StabilityAssuranceTool().isDirectory(at: path) {
                visitorClasses = try StabilityAssuranceTool().readDirectory(at: path)
            } else {
                visitorClasses = try StabilityAssuranceTool().readFile(at: path)
            }
                    
            let reportWriter = try evaluateProduct(
                at: path,
                for: visitorClasses,
                configuration: configuration
            )
            
            options.output.writeReport(reportWriter.report)
        }
    }
}
