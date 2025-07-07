# StabilityAssuranceTool

![Swift Version](https://img.shields.io/badge/Swift-4.2-orange.svg)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

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

[//]: # "[alt text](https://github.com/andrellaflame/StabilityAssuranceTool/blob/main/Resources/testCommandExample.jpg?raw=true)"

> ```$ swift run sat evaluate```

[//]: # "![alt text](https://github.com/andrellaflame/StabilityAssuranceTool/blob/main/Resources/evaluateCommandExample.jpg?raw=true)"

## Documentation

- **Swift Argument Parser**: Documentation for the Swift Argument Parser library used for building the command-line interface.
- **SwiftSyntax**: Documentation for the SwiftSyntax library used for parsing Swift code.
- **StabilityAssuranceTool**: Documentation is available in `Developer Documentation`.

> Note: 
> To open `Developer Documentation`
```
Shift + Command (⌘) + O
``` 

## License

This project is licensed under the [Apache License 2.0](./LICENSE). 

### Intellectual Property Notice

The algorithms and architecture used in this project are the original work of Andrii Sulimenko.

Although not covered by a formal patent, any reuse, modification, or distribution of this work must include attribution.  

Unauthorized patenting of this work or its derivatives is strictly prohibited.

> © 2023 Andrii Sulimenko. 