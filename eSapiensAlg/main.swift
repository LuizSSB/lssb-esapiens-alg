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
        
        debug = args.last == Constants.debugFlag
        
        let weightParamIndex = args.count - (debug ? 2 : 1)
        let weightParam = args[weightParamIndex]
        if weightParam.contains(Constants.weightFlag) {
            // Luiz: you CANNOT take a look at this and tell me Swift has a good
            // string API; there is simply no way. What were they thinking!?
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

enum BoxesError : Error {
    case nonPositiveWeight
}

// Luiz: leaving as var so as to allow debugging down below.
var commandLineArgs: Args
do {
    commandLineArgs = try Args(fromCLI: CommandLine.arguments)
} catch let error as ArgsError {
    fatalError(error.message)
}

func log(_ message: String) {
    if commandLineArgs.debug {
        print("[DEBUG]", message)
    }
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
 caso, essa função demonstra, para apresentação dos logs, algumas otimizações
 para reduzir tal número. Mais especificamente, ela não traz as caixas leves de
 volta enquanto puder levar as mais pesadas para o outro piso sem estourar o
 limite de peso.
 */
func checkBoxTransportPossibility(
    forWeights boxesWeights: [Int], maxWeightDiff: Int
    ) throws -> Bool {

    guard try checkBoxesWeightDiff(
        boxesWeights: boxesWeights, maxDiff: maxWeightDiff
        ) else { return false }
    
    var here = boxesWeights.sorted()
    var there = [Int]()
    
    // Luiz: perhaps, the "better" approach would be to name these variables
    // 'elevator1' and 'elevator2', however, then, for the sake of
    // demonstration, I would have to exchange their values at each iteration so
    // as to demonstrate that the elevator that went up is now coming down, and
    // vice-versa. With these names, this gets implied and everyone's happy.
    var sending = here.removeFirst(),
        receiving = 0
    
    func logTransport() {
        log("sending \(sending), receiving \(receiving), diff \(sending - receiving)")
    }
    
    logTransport()
    while !here.isEmpty {
        there.append(sending)
        
        if there.last! > here.first! {
            // Luiz: acabou de transportar a mais pesada. Reinicia o processo.
            receiving = 0
        } else if here.first! - receiving > maxWeightDiff{ // Luiz
            // Luiz: só traz a última caixa enviada de volta se, ao manter a
            // caixa atual do elevador 2, a diferença de peso estoura o limite.
            receiving = there.removeLast()
            here.append(receiving)
        }
        sending = here.removeFirst()
        logTransport()
    }
    
    there.append(sending)
    log("here: \(here)")
    log("there: \(there)")
    
    return true
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

do {
    let isTransportPossible = try checkBoxTransportPossibility(
        forWeights: commandLineArgs.boxesWeights,
        maxWeightDiff: commandLineArgs.maxWeightDifference
    )
    print(isTransportPossible ? "S" : "N")
} catch let error as BoxesError {
    fatalError("\(error)")
}

// Luiz: debug.
if commandLineArgs.debug {
    commandLineArgs.maxWeightDifference = 8
    commandLineArgs.boxesWeights = [15, 8, 10]
//    commandLineArgs.boxesWeights = [25, 2, 7, 15, 40, 30, 35, 20]
//    commandLineArgs.boxesWeights = [14, 10, 20, 23]
//    commandLineArgs.boxesWeights = [8]
    _ = try? checkBoxTransportPossibility(
        forWeights: commandLineArgs.boxesWeights,
        maxWeightDiff: commandLineArgs.maxWeightDifference
    )
}
