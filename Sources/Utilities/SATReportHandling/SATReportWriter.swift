//
//  SATReportWriter.swift
//
//
//  Created by Andrii Sulimenko on 11.01.2024.
//

import Foundation

/// A struct to generate reports for the Stability Assurance Tool (SAT) in various formats.
struct SATReportWriter {
    /// The directory of the project being analyzed.
    let projectDirectory: String
    /// The scale of the project (e.g., small, medium, large).
    let projectScale: ProjectSize
    /// Evaluated metrics for the project, including their values and marks.
    let evaluatedMetrics: [(String, Double, SATMark)]
    /// Evaluated data for each class in the project.
    let evaluatedData: [ClassInfo]
    /// The output format for the report.
    let outputFormat: OutputFormat
    
    /// Generates the SAT report based on the provided data and format.
    private func getMetricValue(for name: String) -> (value: Double, mark: SATMark) {
        return evaluatedMetrics
            .filter { $0.0 == name }
            .first
            .map { (value: $0.1, mark: $0.2) } ?? (0, .unowned)
    }
    
    public var report: String {
        
        print("Evaluated Metrics: \(evaluatedMetrics)")
        
        let (valueWMC, markWMC) = getMetricValue(for: "WMC")
        let (valueRFC, markRFC) = getMetricValue(for: "RFC")
        let (valueNOC, markNOC) = getMetricValue(for: "NOC")
        let (valueLOCM, markLOCM) = getMetricValue(for: "LOCM")
        let (valueLOC, _) = getMetricValue(for: "LOC")
        
        let overallMark: (String, SATMark) = calculateOverallMark(wmcMark: markWMC, rfcMark: markRFC, nocMark: markNOC, locmMark: markLOCM)
        
        var detailedDescription: [ClassDescription] = []
        for classInstance in evaluatedData {
            let WMCResult = generateComment(metric: "WMC", metricValue: classInstance.WMC.0, mark: classInstance.WMC.1)
            let RFCResult = generateComment(metric: "RFC", metricValue: classInstance.RFC.0, mark: classInstance.RFC.1)
            let NOCResult = generateComment(metric: "NOC", metricValue: classInstance.NOC.0, mark: classInstance.NOC.1)
            let LOCMResult = generateComment(metric: "LOCM", metricValue: classInstance.LOCM.0, mark: classInstance.LOCM.1)
            
            detailedDescription.append(
                ClassDescription(
                    name: classInstance.declaration.name,
                    filePath: classInstance.declaration.filePath,
                    line: classInstance.declaration.line,
                    WMCResult: WMCResult,
                    RFCResult: RFCResult,
                    NOCResult: NOCResult,
                    LOCMResult: LOCMResult
                )
            )
        }
        
        let comment = generateComment(metric: "Overall result", mark: overallMark.1)
        
        let report = SATReport(
            system: "Swift",
            projectDirectory: self.projectDirectory,
            numberOfClasses: self.evaluatedData.count,
            linesOfCode: Int(valueLOC),
            projectScale: self.projectScale.rawValue,
            WMC: Metric(value: valueWMC, mark: markWMC),
            RFC: Metric(value: valueRFC, mark: markRFC),
            NOC: Metric(value: valueNOC, mark: markNOC),
            LOCM: Metric(value: valueLOCM, mark: markLOCM),
            overallMark: overallMark,
            note: comment,
            detailedDescription: detailedDescription
        )
        
        let formattedMessage = SATReportWriter.formatIssueMessage(
            message: "Overall mark: \(overallMark.0)",
            severity: .warning
        )
        
        print(formattedMessage)
        
        return generateReportContext(for: self.outputFormat, from: report)
    }
    
    
    /// Calculates the overall stability mark based on WMC, RFC, and NOC marks.
    /// - Parameters:
    ///   - wmcMark: The WMC mark.
    ///   - rfcMark: The RFC mark.
    ///   - nocMark: The NOC mark.
    ///   - locmMark: The LOCM mark.
    /// - Returns: A tuple containing the overall mark description and mark.
    private func calculateOverallMark(wmcMark: SATMark, rfcMark: SATMark, nocMark: SATMark, locmMark: SATMark) -> (String, SATMark) {
        /// Weighted scoring (could adjust weights as needed)
        let wmcWeight = 0.3
        let rfcWeight = 0.3
        let nocWeight = 0.1
        let locmWeight = 0.3
        
        /// Calculate the overall score
        let overallScore = (wmcMark.score * wmcWeight) + (rfcMark.score * rfcWeight) + (nocMark.score * nocWeight) + (locmMark.score * locmWeight)
        
        /// Determine the mark based on the overall score
        if overallScore >= 0.8 {
            return ("Good", .good)
        } else if overallScore >= 0.5 {
            return ("Accepted", .accepted)
        } else {
            return ("Poor", .poor)
        }
    }
    
    /// Generates a detailed description for each class in the project.
    /// - Returns: An array of `ClassDescription` containing class-specific metric evaluations.
    private func generateClassDescriptions() -> [ClassDescription] {
        return evaluatedData.map { classInstance in
            ClassDescription(
                name: classInstance.declaration.name,
                filePath: classInstance.declaration.filePath,
                line: classInstance.declaration.line,
                WMCResult: generateComment(metric: "WMC", metricValue: classInstance.WMC.0, mark: classInstance.WMC.1),
                RFCResult: generateComment(metric: "RFC", metricValue: classInstance.RFC.0, mark: classInstance.RFC.1),
                NOCResult: generateComment(metric: "NOC", metricValue: classInstance.NOC.0, mark: classInstance.NOC.1),
                LOCMResult: generateComment(metric: "LOCM", metricValue: classInstance.LOCM.0, mark: classInstance.LOCM.1)
            )
        }
    }
    
    /// Generates a comment based on the given metric, value, and mark.
    /// - Parameters:
    ///   - metric: The name of the metric (e.g., "WMC", "RFC", "NOC").
    ///   - metricValue: The value of the metric.
    ///   - mark: The mark assigned to the metric.
    /// - Returns: A string comment describing the metric evaluation.
    private func generateComment(metric: String, metricValue: Int = 0, mark: SATMark = .unowned) -> String {
        switch metric {
        case "WMC":
            return "WMC mark: \(mark.rawValue) (value: \(metricValue))"
        case "RFC":
            return "RFC mark: \(mark.rawValue) (value: \(metricValue))"
        case "NOC":
            return "NOC mark: \(mark.rawValue) (value: \(metricValue))"
        case "LOCM":
            return "LOCM mark: \(mark.rawValue) (value: \(metricValue))"
        default:
            switch mark {
            case .good:
                return """
                The evaluated product demonstrates stability, aligning with stability metrics
                that indicate a satisfactory level of stability.
                """
            case .accepted:
                return """
                The evaluated product shows an acceptable level of stability, meeting the criteria
                outlined in the stability metrics. Recommendations for improvement may be considered
                to enhance overall stability further.
                """
            default:
                return """
                The evaluated product indicates areas for improvement in stability based on the applied
                stability metrics. Consideration of significant adjustments or enhancements is advised
                to achieve a higher level of stability.
                """
            }
        }
    }
    
    /// Generates the report context based on the output format and report data.
    /// - Parameters:
    ///   - format: The format in which the report should be generated (e.g., console, HTML).
    ///   - data: The SAT report data to be included in the report context.
    /// - Returns: A string representing the formatted report.
    private func generateReportContext(for format: OutputFormat, from data: SATReport) -> String {
        switch format {
        case .console:
            return generateConsoleReport(data, fontSensitive: true)
        case .file(_):
            return generateConsoleReport(data, fontSensitive: false)
        case .html:
            return generateHTMLReport(data)
        }
    }
    
    /// Generates the console report from the provided data.
    /// - Parameter data: The SAT report data.
    /// - Returns: A formatted console report string.
    private func generateConsoleReport(_ data: SATReport, fontSensitive: Bool) -> String {
        let detailedDescription = data.detailedDescription.map { classDescription in
            """
            • Class \(classDescription.name)
            File path: \(classDescription.filePath), line: \(classDescription.line)
            \(classDescription.WMCResult)
            \(classDescription.RFCResult)
            \(classDescription.NOCResult)
            \(classDescription.LOCMResult)
            """
        }.joined(separator: "\n")
        
        return """
        \(fontSensitive ? Colors.green : "")PRODUCT STABILITY EVALUATION REPORT\(fontSensitive ? Colors.reset : "")
        
        ------------------------------------------------
            System analyzed: \(fontSensitive ? Colors.red : "")Swift\(fontSensitive ? Colors.reset : "")
        ------------------------------------------------
            Project Overview
        
            􀈖  Project directory: \(projectDirectory)
            􀍞  Number of classes: \(evaluatedData.count)
            􀣠  Lines of code: \(data.linesOfCode)
            􀵬  Project scale: \(projectScale.rawValue)
        
        ------------------------------------------------
            Metrics Summary \(fontSensitive ? Colors.green : "")􀇺\(fontSensitive ? Colors.reset : "")
            
            WMC (`Weighted Method per Class`): \(data.WMC.value) - mark: \(data.WMC.mark)
            RFC (`Response for Class`): \(data.RFC.value) - mark: \(data.RFC.mark)
            NOC (`Number of Children`): \(data.NOC.value) - mark: \(data.NOC.mark)
            LOCM (`Lack of Cohesion of Methods`): \(data.LOCM.value) - mark: \(data.LOCM.mark)
        
            Overall mark: \(data.overallMark.0)
        
        📎 \(fontSensitive ? Colors.yellow : "")NOTE:\(fontSensitive ? Colors.reset : "") \(generateComment(metric: data.overallMark.0, mark: data.overallMark.1))
        
        ------------------------------------------------
            Detailed description 􀬸
        
        \(detailedDescription)
        """
    }
    
    /// Generates the HTML report from the provided data.
    /// - Parameter data: The SAT report data.
    /// - Returns: A formatted HTML report string.
    private func generateHTMLReport(_ data: SATReport) -> String {
        let detailedDescription = data.detailedDescription.map { classDescription in
            """
            <li>
                <p>
                    Class <strong>\(classDescription.name)</strong>
                    <br>    - value: \(classDescription.WMCResult)
                    <br>    - value: \(classDescription.RFCResult)
                    <br>    - value: \(classDescription.NOCResult)
                </p>
            </li>
            """
        }.joined(separator: "")
        
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="description" content="Stability Assurance Tool Report">
            <meta name="author" content="Andrii Sulimenko">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Product Stability Evaluation Report</title>
        </head>
        <body>
        <h1>Product Stability Evaluation Report</h1>
        
        <hr>
        
        <p><strong>System analyzed: </strong>Swift</p>
        
        <hr>
        
        <h3>Project Overview</h3>
        <ul>
            <li><strong>Project directory:</strong> \(data.projectDirectory)</li>
            <li><strong>Number of classes:</strong> \(data.numberOfClasses)</li>
            <li><strong>Lines of code:</strong> \(data.linesOfCode)</li>
            <li><strong>Project scale:</strong> \(data.projectScale)</li>
        </ul>
        
        <hr>
        
        <h3>Metrics Summary</h3>
        <ul>
            <li>
                <p>WMC | Weighted Method per Class <br>    - value: \(data.WMC.value) <br>   - mark: \(data.WMC.mark)</p>
            </li>
            <li>
                <p>RFC   |   Response for Class <br>    - value: \(data.RFC.value) <br>  - mark: \(data.RFC.mark)</p>
            </li>
            <li>
                <p>NOC   |   Number of Children <br>    - value: \(data.NOC.value) <br>  - mark: \(data.NOC.mark)</p>
            </li>
        </ul>
        <p><strong>Overall mark:</strong> \(data.overallMark.0)</p>
        <p><strong>Note:</strong> \(generateComment(metric: data.overallMark.0, mark: data.overallMark.1))</p>
        
        <hr>
        
        <h3>Detailed description</h3>
        <ul>\(detailedDescription)</ul>
        </body>
        </html>
        """
    }
}

// MARK: - Editor-based output
extension SATReportWriter {
    /// Generates a detailed message for a class evaluation issue that is disaplyed in the editor.
    /// - Parameters:
    ///   - classInstance: Observed class instance.
    ///   - message: The message or recommendation for the class.
    /// - Returns: A formatted string representing the issue message.
    static func formatIssueMessage(
        _ classInstance: ClassInfo? = nil,
        message: String,
        severity: MetricSeverity
    ) -> String {
        let location = classInstance.map { "\($0.declaration.filePath): \($0.declaration.line): " } ?? ""
        return "\(location)\(severity.rawValue): \(message)"
    }
}
