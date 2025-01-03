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
    let evaluatedMetrics: [(String, any Numeric, SATMark)]
    /// Evaluated data for each class in the project.
    let evaluatedData: [ClassInfo]
    /// The output format for the report.
    let outputFormat: OutputFormat
    
    /// Generates the SAT report based on the provided data and format.
    private func getMetricValue(for name: String) -> (value: Int, mark: SATMark) {
        return evaluatedMetrics
            .filter { $0.0 == name }
            .first
            .map { (value: $0.1 as? Int ?? 0, mark: $0.2) } ?? (0, .unowned)
    }
    
    public var report: String {
        let (valueWMC, markWMC) = getMetricValue(for: "WMC")
        let (valueRFC, markRFC) = getMetricValue(for: "RFC")
        let (valueNOC, markNOC) = getMetricValue(for: "NOC")
        let (valueLOC, _) = getMetricValue(for: "LOC")
        
        var overallMark: (String, SATMark) = ("", .unowned)
        
        if markWMC == .good && markNOC == .good
            || markWMC == .accepted && markRFC == .good && markNOC == .good
            || markWMC == .good && markRFC == .good && markNOC == .accepted {
            overallMark = ("Good", .good)
        } else if markRFC == .good && markNOC == .good
                    || markWMC == .good && markRFC == .poor && markNOC == .accepted
                    || markWMC == .accepted && markRFC == .poor && markNOC == .good
                    || markWMC == .accepted && markRFC == .poor && markNOC == .accepted
                    || markWMC == .accepted && markRFC == .accepted && markNOC == .accepted {
            overallMark = ("Accepted", .accepted)
        } else {
            overallMark = ("Poor", .poor)
        }
        
        var detailedDescription: [ClassDescription] = []
        for classInstance in evaluatedData {
            let WMCResult = generateComment(metric: "WMC", metricValue: classInstance.WMC.0, mark: classInstance.WMC.1)
            let RFCResult = generateComment(metric: "RFC", metricValue: classInstance.RFC.0, mark: classInstance.RFC.1)
            let NOCResult = generateComment(metric: "NOC", metricValue: classInstance.NOC.0, mark: classInstance.NOC.1)
            
            detailedDescription.append(
                ClassDescription(
                    name: classInstance.name,
                    WMCResult: WMCResult,
                    RFCResult: RFCResult,
                    NOCResult: NOCResult
                )
            )
        }
        
        let comment = generateComment(metric: "Overall result", mark: overallMark.1)
        
        let report = SATReport(
            system: "Swift",
            projectDirectory: self.projectDirectory,
            numberOfClasses: self.evaluatedData.count,
            linesOfCode: valueLOC,
            projectScale: self.projectScale.rawValue,
            WMC: Metric(value: valueWMC, mark: markWMC),
            RFC: Metric(value: valueRFC, mark: markRFC),
            NOC: Metric(value: valueNOC, mark: markNOC),
            overallMark: overallMark,
            note: comment,
            detailedDescription: detailedDescription
        )
        
        return generateReportContext(for: self.outputFormat, from: report)
    }
    
    
    /// Calculates the overall stability mark based on WMC, RFC, and NOC marks.
    /// - Parameters:
    ///   - wmcMark: The WMC mark.
    ///   - rfcMark: The RFC mark.
    ///   - nocMark: The NOC mark.
    /// - Returns: A tuple containing the overall mark description and mark.
    private func calculateOverallMark(wmcMark: SATMark, rfcMark: SATMark, nocMark: SATMark) -> (String, SATMark) {
        if (wmcMark == .good && nocMark == .good)
            || (wmcMark == .accepted && rfcMark == .good && nocMark == .good)
            || (wmcMark == .good && rfcMark == .good && nocMark == .accepted) {
            return ("Good", .good)
        } else if (rfcMark == .good && nocMark == .good)
                    || (wmcMark == .good && rfcMark == .poor && nocMark == .accepted)
                    || (wmcMark == .accepted && rfcMark == .poor && nocMark == .good)
                    || (wmcMark == .accepted && rfcMark == .poor && nocMark == .accepted)
                    || (wmcMark == .accepted && rfcMark == .accepted && nocMark == .accepted) {
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
                name: classInstance.name,
                WMCResult: generateComment(metric: "WMC", metricValue: classInstance.WMC.0, mark: classInstance.WMC.1),
                RFCResult: generateComment(metric: "RFC", metricValue: classInstance.RFC.0, mark: classInstance.RFC.1),
                NOCResult: generateComment(metric: "NOC", metricValue: classInstance.NOC.0, mark: classInstance.NOC.1)
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
            \(classDescription.WMCResult)
            \(classDescription.RFCResult)
            \(classDescription.NOCResult)
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
