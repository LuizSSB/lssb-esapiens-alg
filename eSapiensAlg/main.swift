//
//  main.swift
//  eSapiensAlg
//
//  Created by Luiz SSB on 2/3/19.
//  Copyright © 2019 Luiz SSB. All rights reserved.
//

import Foundation

struct Constants {
    static let weightFlag = "--weight="
    static let debugFlag = "--debug"
    static let defaultWeight = 8
    static let numberOfBoxesIndex = 1
    static let firstBoxWeightIndex = 2
}

struct ArgsError: Error {
    let message: String
    
    init(message: String) {
        self.message = message + """
         Must receive one of following:
        - positive number of boxes, followed by their weights as a string of space-separated integers;
        - positive number of boxes, followed by the weight of each box as an integer.
        Optionally, you can also:
        - put "\(Constants.weightFlag)<weight>" after the previous parameters, to set a maximum weight difference.
        - put "\(Constants.debugFlag)" at the end, to view debug log.
        """
    }
}

struct Args {
    let boxesWeights: [Int]
    let maxWeightDifference: Int
    let debug: Bool
    
    static let defaultArgs = Args(boxesWeights: [
        10, 4, 15
        ])

    init(fromCLI args: [String]) throws {
        guard args.count > 1 else {
            self = Args.defaultArgs
            print("No arguments provided. Running with default configuration:\n\(self)")
            return
        }
        
        guard args.count >= 3 else {
            throw ArgsError(message: "Insufficient number of args.")
        }

        guard let numberOfBoxes = Int(args[Constants.numberOfBoxesIndex]) else {
            throw ArgsError(message: "C'mon, give me at least one box, will ya?")
        }
        
        debug = args.last == Constants.debugFlag
        
        let weightParamIndex = args.count - (debug ? 2 : 1)
        let weightParam = args[weightParamIndex]
        if weightParam.contains(Constants.weightFlag) {
            // Luiz: you CANNOT take a look at this and tell me this is a good
            // API. What were they thinking!?
            let index = weightParam.index(
                weightParam.startIndex,
                offsetBy: Constants.weightFlag.count
            )
            let sub = weightParam.suffix(from: index)
            guard let paramValue = Int(sub) else {
                throw ArgsError(message: "Invalid max weight parameter")
            }
            maxWeightDifference = paramValue
        } else {
            maxWeightDifference = Constants.defaultWeight
        }
        
        let strBoxWeights =
            args[Constants.firstBoxWeightIndex].contains(" ")
                ? args[Constants.firstBoxWeightIndex]
                    .split(separator: " ")
                    .map { $0.description }
                : Array(args[
                    Constants.firstBoxWeightIndex..<weightParamIndex
                ])
        
        guard numberOfBoxes == strBoxWeights.count else {
            throw ArgsError(message: "Provided number of boxes don't match actual number of boxes.")
        }
        
        boxesWeights = try strBoxWeights.map { box in
                guard let boxWeight = Int(box) else {
                    throw ArgsError(message: "Invalid box weight \(box)")
                }
                return boxWeight
            }
    }
    
    init(boxesWeights: [Int], maxWeightDifference: Int = Constants.defaultWeight, debug: Bool = true) {
        self.boxesWeights = boxesWeights
        self.debug = debug
        self.maxWeightDifference = maxWeightDifference
    }
}

let commandLineArgs: Args
do {
    commandLineArgs = try Args(fromCLI: CommandLine.arguments)
//    commandLineArgs = try Args(fromCLI: ["", "3", "15", "8", "10", "--weight=7", "--debug"])
//        commandLineArgs = Args(boxesWeights: [25, 2, 7, 15, 40, 30, 35, 20])
//        commandLineArgs = Args(boxesWeights: [14, 10, 20, 23])
//        commandLineArgs = Args(boxesWeights: [8])
    
    print(commandLineArgs)
//    commandLineArgs = Args(boxesWeights: [15, 8, 10])
//    commandLineArgs = Args(boxesWeights: [25, 2, 7, 15, 40, 30, 35, 20])
//    commandLineArgs = Args(boxesWeights: [14, 10, 20, 23])
//    commandLineArgs = Args(boxesWeights: [8])
} catch let error as ArgsError {
    fatalError(error.message)
}

func log(_ message: String) {
    if commandLineArgs.debug {
        print("[DEBUG]", message)
    }
}

enum BoxesError : Error {
    case nonPositiveWeight
}

func checkBoxTransportPossibility(
    forWeights boxesWeights: [Int], maxWeightDiff: Int
    ) throws -> Bool {

    guard try checkBoxesWeightDiff(
        boxesWeights: boxesWeights, maxDiff: maxWeightDiff
        ) else { return false }
    
    var here = boxesWeights.sorted()
    var there = [Int]()
    var elevator1 = here.removeFirst() // used to send
    var elevator2 = 0 // used to receive
    
    func logTransport() {
        log("sending \(elevator1), receiving \(elevator2), diff \(elevator1 - elevator2)")
    }
    
    logTransport()
    while !here.isEmpty {
        there.append(elevator1)
        
        if there.last! > here.first! {
            elevator2 = 0
        } else if here.first! - elevator2 > maxWeightDiff{
            elevator2 = there.removeLast()
            here.append(elevator2)
        }
        elevator1 = here.removeFirst()
        logTransport()
    }
    
    there.append(elevator1)
    log("here: \(here)")
    log("there: \(there)")
    
    return true
}

func checkBoxesWeightDiff(boxesWeights: [Int], maxDiff: Int) throws
    -> Bool {
    var prevWeight = 0
    for weight in boxesWeights.sorted() {
        guard weight >= 0 else {
            throw BoxesError.nonPositiveWeight
        }
        
        if weight - prevWeight > maxDiff {
            return false
        }
        
        prevWeight = weight
    }
    return true
}

