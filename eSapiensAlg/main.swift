//
//  main.swift
//  eSapiensAlg
//
//  Created by Luiz SSB on 2/3/19.
//  Copyright © 2019 Luiz SSB. All rights reserved.
//

import Foundation

enum BoxesError : Error {
    case nonPositiveWeight
}

/**
 Given an array of weights, sorts it and, for each element, checks whether the
 difference in weight between it and its neighbors exceeds a given value.
 
 - returns:
 `true` if the difference of weight between boxes never exceeds the value of
 `maxDiff`, `false` otherwise
 
 - throws:
 `BoxesError.nonPositiveWeight`, if any box has null or negative weight.
 
 - parameters
 - boxesWeights: array of boxes to be checked.
 - maxDiff: maximum allowed difference in weight between two boxes.
 */
func checkBoxesWeightDiff(boxesWeights: [Int], maxDiff: Int) throws
    -> Bool {
        var prevWeight = 0
        for weight in boxesWeights.sorted() {
            guard weight > 0 else {
                throw BoxesError.nonPositiveWeight
            }
            
            if weight - prevWeight > maxDiff {
                return false
            }
            
            prevWeight = weight
        }
        return true
}

/**
 Verifica se um conjunto de caixas pode ser transportado de um piso para outro
 usando o mecanismo de polias descrito no enunciado do teste.
 
 - returns:
 `true` se o transporte das caixas pode ser realizado, `false` do contrário.
 
 - throws:
 `BoxesError.nonPositiveWeight`, se alguma das caixas tem peso nulo ou negativo.
 
 - parameters
 - forWeights boxesWeights: array com o peso das caixas a serem transportadas.
 - maxWeightDiff: diferença máxima de peso entre os elevadores da polia.
 - debugging: indica modo de debug.
 
 O mecanismo funciona por meio de dois elevadores conectados através de uma
 corda que passa por uma polia; quando um deles sobe, o outro desce. Contudo, o
 mecanismo apresenta uma limitação: a diferença de peso entre os conteúdos de
 cada elevador nunca pode exceder um determinado peso (postulado no enunciado
 como **8**, embora, aqui, parametrizável).
 
 Sendo assim, esta função verifica se, dado um um array com os pesos das caixas
 em um conjunto, é possível transportar todas elas de um piso para outro, usando
 esse mecanismo de polia.
 
 Verdade seja dita, tal verificação pode consistir somente em ordenar as caixas
 por peso e verificar se a diferença de peso entre duas delas consecutivas não
 excede o máximo especificado. A razão para isso é que, uma vez confirmado esse
 detalhe, **sempre** será possível transportá-las todas sem quebrar o mecanismo.
 Isso, então, é feito transportando as caixas, da mais leve para a mais pesada,
 para lá e de volta; enquanto uma pesada vai, a anterior, mais leve, volta,
 exceto pela caixa mais pesada, que não é retornada. A partir daí, o processo é
 reiniciado, mas agora com uma caixa a menos no piso de cá. O ciclo, obviamente,
 encerra quando todas as caixas terminarem de ser transportadas. Dado isto, a
 verdadeira *estrela do show* aqui é a função
 checkBoxesWeightDiff(boxesWeights:maxDiff:), que faz essa verificação.
 
 Esta função aqui meramente apresenta um algoritmo para imprimir no console o
 processo de transporte das caixas, a fim de tornar o processo mais *visual*.
 Isso, todavia, é feito somente quando passada a flag de debug.
 
 Nota: *per* enunciado, o número de viagens dos elevadores é ignorado. Em todo
 caso, essa função demonstra, para apresentação dos logs, uma otimização simples
 para reduzir este número: caso o peso da próxima caixa seja menor que a
 diferença máxima de peso, não retorna a caixa atual.
 */
func checkBoxTransportPossibility(
    forWeights boxesWeights: [Int],
    maxWeightDiff: Int,
    debugging: Bool = false
    ) throws -> Bool {
    
    guard boxesWeights.count > 0 else { return true }
    
    guard try checkBoxesWeightDiff(
        boxesWeights: boxesWeights, maxDiff: maxWeightDiff
        ) else { return false }
    
    guard debugging else {
        return true
    }
    
    func log(_ message:String) {
        if debugging {
            print("[DEBUG]", message)
        }
    }
    
    var here = boxesWeights.sorted()
    var there = [Int]()
    
    // Luiz: perhaps, a "better" approach would be to name these variables
    // 'elevator1' and 'elevator2', however, then, for the sake of the
    // demonstration, I would have to exchange their values at each iteration so
    // as to demonstrate that the elevator that went up is now coming down, and
    // vice-versa. Using these names, this is implied and everyone's happy.
    var sending: Int,
        receiving = 0
    
    repeat {
        sending = here.removeFirst()
        log("sending \(sending), receiving \(receiving), diff \(sending - receiving)")
        
        there.append(sending)
        
        if (here.count > 0) {
            if there.last! > here.first! || here.first! <= maxWeightDiff {
                // Luiz: acabou de transportar a mais pesada ou pode transportar
                // sem contrapeso. Reinicia o processo.
                receiving = 0
            } else {
                receiving = there.removeLast()
                here.append(receiving)
            }
        }
    } while (!here.isEmpty)
    
    log("here: \(here)")
    log("there: \(there)")
    
    return true
}

struct Constants {
    static let optionPrefix = "--"
    static let weightFlag = "\(Constants.optionPrefix)weight="
    static let debugFlag = "\(Constants.optionPrefix)debug"
    static let defaultWeight = 8
    static let numberOfBoxesIndex = 1
    static let firstBoxWeightIndex = 2
}

struct ArgsError: Error {
    let message: String
    
    init(message: String) {
        self.message = message + """
        
        Invocation must provide one of the following:
        - positive number of boxes, followed by their weights as a string of space-separated integers;
        - positive number of boxes, followed by the weight of each box as an integer.
        Optionally, you can also:
        - put "\(Constants.weightFlag)<weight>" after the previous parameters, to set a maximum weight difference.
        - put "\(Constants.debugFlag)" at the end, to view debug log.
        """
    }
}

struct Args {
    var boxesWeights: [Int]
    var maxWeightDifference: Int
    var debug: Bool
    
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
        
        let debugArgIndex = args.index { $0.contains(Constants.debugFlag) }
        debug = debugArgIndex != nil
        
        let lastBoxIndex: Int
        let weightArgIndex = args.index { $0.contains(Constants.weightFlag) }
        if let weightArgIndex = weightArgIndex {
            let weightArg = args[weightArgIndex]
            
            // Luiz: you CANNOT take a look at this and honestly tell me Swift
            // has a good string API; there is simply no way.
            // "WHAT WERE THEY THINKING" - avgn
            let index = weightArg.index(
                weightArg.startIndex,
                offsetBy: Constants.weightFlag.count
            )
            let sub = weightArg.suffix(from: index)
            guard let argValue = Int(sub) else {
                throw ArgsError(message: "Invalid max weight parameter")
            }
            maxWeightDifference = argValue
            lastBoxIndex = weightArgIndex
        } else {
            maxWeightDifference = Constants.defaultWeight
            lastBoxIndex = debug ? debugArgIndex! : args.count
        }
        
        let strBoxWeights =
            args[Constants.firstBoxWeightIndex].contains(" ")
                ? args[Constants.firstBoxWeightIndex]
                    .split(separator: " ")
                    .map { $0.description }
                : Array(args[
                    Constants.firstBoxWeightIndex..<lastBoxIndex
                    ])
        
        boxesWeights = try strBoxWeights.map { box in
            guard let boxWeight = Int(box) else {
                throw ArgsError(message: "Invalid box weight \(box)")
            }
            return boxWeight
        }
        
        guard numberOfBoxes == strBoxWeights.count else {
            throw ArgsError(message: "Provided number of boxes doesn't match actual number of boxes.")
        }
    }
    
    init(boxesWeights: [Int], maxWeightDifference: Int = Constants.defaultWeight, debug: Bool = true) {
        self.boxesWeights = boxesWeights
        self.debug = debug
        self.maxWeightDifference = maxWeightDifference
    }
}

// Luiz: leaving as var so as to allow debugging down below.
let commandLineArgs: Args
do {
    commandLineArgs = try Args(fromCLI: CommandLine.arguments)
    let isTransportPossible = try checkBoxTransportPossibility(
        forWeights: commandLineArgs.boxesWeights,
        maxWeightDiff: commandLineArgs.maxWeightDifference,
        debugging: commandLineArgs.debug
    )
    print(isTransportPossible ? "S" : "N")
} catch let error as ArgsError {
    fatalError(error.message)
} catch let error as BoxesError {
    fatalError("\(error)")
}

// Luiz: debug.
if commandLineArgs.debug {
    print("\nDebugging")
    let maxWeightDifference = 8
    let testDataSet = [
        [15, 8, 10],
        [25, 2, 7, 15, 40, 30, 35, 20],
        [14, 10, 20, 23],
        [8],
        [1, 8, 15, 16, 17, 18, 25, 0],
        [1, 8, 15, 16, 17, 18, 25]
    ]
    
    for idx in 0..<testDataSet.count {
        print("Test case", idx, testDataSet[idx])
        do {
            print("transport:", try checkBoxTransportPossibility(
                forWeights: testDataSet[idx],
                maxWeightDiff: maxWeightDifference, debugging: true
            ))
        } catch let error as BoxesError {
            print("error", error)
        }
        print("\n")
    }
}
