//
//  main.swift
//  eSapiensAlg
//
//  Created by Luiz SSB on 2/3/19.
//  Copyright © 2019 Luiz SSB. All rights reserved.
//

import Foundation

struct Constants {
    static var debug = true
}

func log(_ message: String) {
    if Constants.debug {
        print("[DEBUG]", message)
    }
}

enum WeightError : Error {
    case nonPositiveWeight
}

func checkBoxTransportPossibility(
    forWeights boxesWeights: [Int], maxWeightDiff: Int
    ) throws -> Bool {
    do {
        let diffOK = try checkBoxesWeightDiff(
            boxesWeights: boxesWeights, maxDiff: maxWeightDiff
        )
        if !diffOK {
            return false
        }
    } catch {
        throw error
    }
    
    //
    var here = boxesWeights.sorted()
    var there = [Int]()
    var elevator1 = here.removeFirst() // used to send
    var elevator2 = 0 // used to receive
    
    while !here.isEmpty {
        log("sending \(elevator1), receiving \(elevator2), diff \(elevator1 - elevator2)")
        there.append(elevator1)
        
        if there.last! > here.first! {
            elevator2 = 0
        } else if here.first! - elevator2 > maxWeightDiff{
            elevator2 = there.removeLast()
            here.append(elevator2)
        }
        elevator1 = here.removeFirst()
    }
    log("sending \(elevator1), receiving \(elevator2), diff \(elevator1 - elevator2)")
    
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
            throw WeightError.nonPositiveWeight
        }
        
        if weight - prevWeight > maxDiff {
            return false
        }
        
        prevWeight = weight
    }
    return true
}

print("\n\nCASE 1")
try? checkBoxTransportPossibility(forWeights: [15, 8, 10], maxWeightDiff: 8)

print("\n\nCASE2")
try? checkBoxTransportPossibility(forWeights: [25, 2, 7, 15, 40, 30, 35, 20], maxWeightDiff: 8)

print("\n\nCASE2")
try? checkBoxTransportPossibility(forWeights: [14, 10, 20, 23], maxWeightDiff: 8)

print("\n\nCASE2")
try? checkBoxTransportPossibility(forWeights: [8], maxWeightDiff: 8)
