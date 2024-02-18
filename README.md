# StabilityAssuranceTool

![Swift Version](https://img.shields.io/badge/Swift-4.2-orange.svg) ![Static Badge](https://img.shields.io/badge/@copyright-NaUKMA-blue)

![GitHub watchers](https://img.shields.io/github/watchers/andrellaflame/StabilityAssuranceTool)


StabilityAssuranceTool is a Swift Package Manager (SPM) tool designed to provide quality checks for Swift projects. It offers various metrics to evaluate the stability and quality of Swift codebases.

## Features

- **Code Metrics**: Provides metrics such as Weighted Method Count (WMC), Response For a Class (RFC), Number Of Children (NOC), and Lines of Code (LOC) to assess the stability and complexity of Swift code.
- **Report Generation**: Generates detailed reports with metrics summaries and class-level descriptions to provide insights into the analyzed Swift project.
- **Command-Line Interface (CLI)**: Offers a command-line interface for easy integration into development workflows.

## Installation

To use StabilityAssuranceTool in your Swift project, add it as a dependency in your `Package.swift` file:

```
swift
dependencies: [
    .package(url: "https://github.com/andrellaflame/StabilityAssuranceTool.git", from: "1.0.0")
]
```

## Usage

### StabilityAssuranceTool provides several subcommands to interact with:

- ```test``` (default): Test command to demnstrate the work of SPM tool.
- ```showData```: Show collected data for the specified filepath.
- ```evaluate```: Evaluate the stability of the source code for the specified filepath.
    
    #### Evaluate subcommands
    
    - ```rfc```: A stability assurance tool command to evaluate Response for Class metric for Swift projects.
    - ```wmc```: A stability assurance tool command to evaluate Weighted Method per Class metric for Swift projects.
    - ```noc```: A stability assurance tool command to evaluate Number of Children metric for Swift projects.
    - ```countLines```: A tool command to count the number of lines for Swift projects.
    - ```stats``` (Default): The main stability assurance tool command to evaluate Overall stability mark for Swift projects.

> Example usage: 
>
> ```$ swift run sat test```

![alt text](https://github.com/andrellaflame/StabilityAssuranceTool/blob/main/Sources/Utilities/DocumentationImages/testCommandExample.jpg?raw=true)

> ```$ swift run sat evaluate```

![alt text](https://github.com/andrellaflame/StabilityAssuranceTool/blob/main/Sources/Utilities/DocumentationImages/evaluateCommandExample.jpg?raw=true)

## Documentation

- **Swift Argument Parser**: Documentation for the Swift Argument Parser library used for building the command-line interface.
- **SwiftSyntax**: Documentation for the SwiftSyntax library used for parsing Swift code.
- **StabilityAssuranceTool**: Documentation is available in `Developer Documentation`.

> Note: 
> To open `Developer Documentation`
```
shift + command + o
``` 

## License

All rights for this software belong to `National University of Kyiv-Mohyla Academy` as it's part of the Bachelor's research project done by Andrii Sulimenko, 3rd year Software Engineering student

> Author: Andrii Sulimenko
