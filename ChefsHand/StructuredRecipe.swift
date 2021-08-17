//
//  StructuredRecipe.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 17/8/21.
//

import Foundation

public class StructuredRecipe: NSObject, Codable {
    var name: String
    var ingredients: [StructuredIngredient]
    var method: [StructuredStep]
    
    init(name: String, ingredients: [StructuredIngredient], method: [StructuredStep]) {
        self.name = name
        self.ingredients = ingredients
        self.method = method
    }
}

public class StructuredIngredient: NSObject, Codable {
    var text: String
    var isDone: Bool
    
    init(text: String, isDone: Bool){
        self.text = text
        self.isDone = isDone
    }
}

public class StructuredStep: NSObject, Codable {
    var instruction: String
    var isDone: Bool
    var cookingTimes: [CookingTimer]
    
    init(instruction: String, isDone: Bool, cookingTimes: [CookingTimer]){
        self.instruction = instruction
        self.isDone = isDone
        self.cookingTimes = cookingTimes
    }
}

public class CookingTimer: NSObject, Codable {
    var time: Int
    var timeDefStart: Int
    var timeDefEnd: Int
    
    init(time: Int, timeDefStart: Int, timeDefEnd: Int){
        self.time = time
        self.timeDefStart = timeDefStart
        self.timeDefEnd = timeDefEnd
    }
}

struct TasteRecipe: Decodable {
    var recipeInstructions: [String]
    var recipeIngredient: [String]
}

extension Decodable {
    init(from: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
