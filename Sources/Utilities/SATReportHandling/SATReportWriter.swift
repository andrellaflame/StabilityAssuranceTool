//
//  SATReportWriter.swift
//
//
//  Created by Andrii Sulimenko on 11.01.2024.
//

import Foundation

/// Add Stability Assurance Tool (SAT) reports in different formats.
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
    var report: String {
        let (_, valueWMC, markWMC) = evaluatedMetrics
            .filter { $0.0 == "WMC" }
            .first ?? ("WMC", 0, .unowned)
        
        let (_, valueRFC, markRFC) = evaluatedMetrics
            .filter { $0.0 == "RFC" }
            .first ?? ("RFC", 0, .unowned)
        
        let (_, valueNOC, markNOC) = evaluatedMetrics
            .filter { $0.0 == "NOC" }
            .first ?? ("NOC", 0, .unowned)
        
        let (_, valueLOC, _) = evaluatedMetrics
            .filter { $0.0 == "LOC" }
            .first ?? ("LOC", 0, .unowned)
        
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
        
        let comment = self.generateComment(metric: "Overall result", mark: overallMark.1)
        
        let report = SATReport(
            system: "Swift",
            projectDirectory: self.projectDirectory,
            numberOfClasses: self.evaluatedData.count,
            linesOfCode: valueLOC as? Int ?? 0,
            projectScale: self.projectScale.rawValue,
            WMC: Metric(value: valueWMC, mark: markWMC),
            RFC: Metric(value: valueRFC, mark: markRFC),
            NOC: Metric(value: valueNOC, mark: markNOC),
            overallMark: overallMark,
            note: comment,
            detailedDescription: detailedDescription
        )
        
        let contextedReport = generateReportContext(for: self.outputFormat, from: report)
        return contextedReport
    }
    
    /// Generates a comment based on the given metric, value, and mark.
    private func generateComment(metric: String, metricValue: Int = 0, mark: SATMark = .unowned) -> String {
        var comment = ""
        
        switch metric {
        case "WMC":
            comment = "WMC mark: \(mark.rawValue) (value: \(metricValue))"
        case "RFC":
            comment = "RFC mark: \(mark.rawValue) (value: \(metricValue))"
        case "NOC":
            comment = "NOC mark: \(mark.rawValue) (value: \(metricValue))"
        default:
            if mark == .good {
                comment =
                    """
                    The evaluated product demonstrates stability,
                                aligning with stability metrics that indicate a
                                satisfactory level of stability.
                    """
            } else if mark == .accepted {
                comment =
                    """
                    The evaluated product shows an acceptable level of
                                stability, meeting the criteria outlined in the stability metrics.
                                Recommendations for improvement may be considered
                                to enhance overall stability further.
                    """
            } else {
                comment =
                    """
                    The evaluated product indicates areas for
                                improvement in stability based on the applied
                                stability metrics. Consideration of significant
                                adjustments or enhancements is advised to
                                achieve a higher level of stability.
                    """
            }
        }
        
        return comment
    }
    
    /// Generates the report context based on the output format and report data.
    private func generateReportContext(for format: OutputFormat, from data: SATReport) -> String {
        
        var reportContext = ""
        var detailedDescription = ""
        
        switch format {
        case .console:
            for classDescription in data.detailedDescription {
                detailedDescription += "\n         • Class \(classDescription.name)\n"
                detailedDescription += "         \(classDescription.WMCResult)\n"
                detailedDescription += "         \(classDescription.RFCResult)\n"
                detailedDescription += "         \(classDescription.NOCResult)\n"
            }
            
            reportContext =
                            """
                            
                                       \(Colors.green)PRODUCT STABILITY EVALUATION REPORT\(Colors.reset)
                            
                                ------------------------------------------------
                                    System analyzed: \(Colors.red)Swift 􀫊\(Colors.reset)
                                ------------------------------------------------
                                    Project Overview
                            
                                    􀈖  Project directory: \(projectDirectory)
                                    􀍞  Number of classes: \(evaluatedData.count)
                                    􀣠  Lines of code: \(data.linesOfCode)
                                    􀵬  Project scale: \(projectScale.rawValue)
                            
                                ------------------------------------------------
                                    Metrics Summary \(Colors.green)􀇺\(Colors.reset)
                                    
                                    WMC (`Weighted Method per Class`): \(data.WMC.value)
                                        - mark: \(data.WMC.mark)
                                    RFC (`Response for Class`): \(data.RFC.value)
                                        - mark: \(data.RFC.mark)
                                    NOC (`Number of Children`): \(data.NOC.value)
                                        - mark: \(data.NOC.mark)
                                    
                                    Overall mark: \(data.overallMark.0)
                                
                                    📎 \(Colors.yellow)NOTE:\(Colors.reset) \(generateComment(metric: data.overallMark.0, mark: data.overallMark.1))
                            
                                ------------------------------------------------
                                    Detailed description 􀬸
                                    
                                    \(detailedDescription)
                            
                            """
            
            return reportContext
        case .html:
            detailedDescription += "<ul>"
            
            for classDescription in data.detailedDescription {
                detailedDescription +=
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
            }
            detailedDescription += "</ul>"
            
            reportContext =
                            """
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
                            <p>\(detailedDescription)</p>
                            <!-- Save button -->
                            <button onclick="downloadReport()">Save Report</button>
                            <script>
                                function downloadReport() {
                                    var htmlContent = document.documentElement.outerHTML;
                                    var blob = new Blob([htmlContent], { type: 'text/html' });
                                    var a = document.createElement('a');
                            
                                    a.download = 'product_report.html';
                                    a.href = window.URL.createObjectURL(blob);
                            
                                    document.body.appendChild(a);
                                    a.click();
                            
                                    document.body.removeChild(a);
                                }
                            </script>
                            </body>
                            </html>
                            """
            return reportContext
        }
    }
}
