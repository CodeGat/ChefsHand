//
//  StructuredRecipe.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 17/8/21.
//

import Foundation
import CoreData

public class StructuredRecipe: NSObject, Codable {
    var name: String
    var ingredients: [StructuredIngredient]
    var method: [StructuredStep]
    
    init(name: String, ingredients: [StructuredIngredient], method: [StructuredStep]) {
        self.name = name
        self.ingredients = ingredients
        self.method = method
    }
    
    func convertToNSManagedObject(usingContext context: NSManagedObjectContext) -> NSManagedObject {
        let recipeEntity = NSEntityDescription.entity(forEntityName: "CoreRecipe", in: context)
        let newRecipe = NSManagedObject(entity: recipeEntity!, insertInto: context)
        
        newRecipe.setValue(self.name, forKey: "name")
        // newRecipe.setValue(self.image, forKey: "image")
        
        let managedIngredients: [NSManagedObject] = self.ingredients.map{$0.convertToNSManagedObject(usingContext: context)}
        let managedIngredientsSet = NSOrderedSet(array: managedIngredients)
        newRecipe.setValue(managedIngredientsSet, forKey: "hasIngredient")
        
        let managedSteps: [NSManagedObject] = self.method.map{$0.convertToNSManagedObject(usingContext: context)}
        let managedStepsSet = NSOrderedSet(array: managedSteps)
        newRecipe.setValue(managedStepsSet, forKey: "hasStep")
        
        return newRecipe
    }
}

public class StructuredIngredient: NSObject, Codable {
    var text: String
    var isDone: Bool
    
    init(text: String, isDone: Bool){
        self.text = text
        self.isDone = isDone
    }
    
    func convertToNSManagedObject(usingContext context: NSManagedObjectContext) -> NSManagedObject {
        let ingredientEntity = NSEntityDescription.entity(forEntityName: "Ingredient", in: context)
        let newIngredient = NSManagedObject(entity: ingredientEntity!, insertInto: context)
        newIngredient.setValue(self.text, forKey: "text")
        newIngredient.setValue(self.isDone, forKey: "isDone")
        
        return newIngredient
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
    
    func convertToNSManagedObject(usingContext context: NSManagedObjectContext) -> NSManagedObject {
        let stepEntity = NSEntityDescription.entity(forEntityName: "Step", in: context)
        let newStep = NSManagedObject(entity: stepEntity!, insertInto: context)
        
        newStep.setValue(self.instruction, forKey: "instruction")
        newStep.setValue(self.isDone, forKey: "isDone")
        
        let managedCookingTimes: [NSManagedObject] = self.cookingTimes.map{$0.convertToNSManagedObject(usingContext: context)}
        let managedCookingTimesSet = NSMutableOrderedSet(array: managedCookingTimes)
        newStep.setValue(managedCookingTimesSet, forKey: "hasCookingTime")
        
        return newStep
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
    
    func convertToNSManagedObject(usingContext context: NSManagedObjectContext) -> NSManagedObject {
        let cookingTimeEntity = NSEntityDescription.entity(forEntityName: "CookingTime", in: context)
        let newCookingTime = NSManagedObject(entity: cookingTimeEntity!, insertInto: context)
        
        newCookingTime.setValue(self.time, forKey: "time")
        newCookingTime.setValue(self.timeDefStart, forKey: "timeDefStart")
        newCookingTime.setValue(self.timeDefEnd, forKey: "timeDefEnd")
        
        return newCookingTime
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
