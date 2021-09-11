//
//  RealmRecipe.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 11/9/21.
//

import Foundation
import RealmSwift

public class RealmRecipe: Object, DatabaseObjectDecodable {
    @Persisted var name: String
    @Persisted var location: String
    @Persisted var url: String?
    @Persisted var image: Data?
    @Persisted var ingredients: List<RealmIngredient>
    @Persisted var method: List<RealmStep>
    
    convenience init(name: String?, location: String?, url: URL, image: Data?, ingredients: [Ingredient], method: [Step]){
        self.init()
        self.name = name ?? "Unknown"
        self.location = location ?? "Unknown Location"
        self.url = url.absoluteString
        
        self.ingredients = List<RealmIngredient>()
        let realmIngredients = ingredients.map{RealmIngredient(text: $0.text, isDone: $0.isDone)}
        self.ingredients.append(objectsIn: realmIngredients)
        
        self.method = List<RealmStep>()
        for step in method {
            self.method.append(RealmStep(text: step.text, isDone: step.isDone, cookingTimes: step.cookingTimes))
        }
    }
    
    func dbDecode() -> Recipe {
        let ingredients: [Ingredient] = self.ingredients.map{Ingredient(text: $0.text, isDone: $0.isDone)}
        let method: [Step] = self.method.map{Step(
            text: $0.text,
            isDone: $0.isDone,
            cookingTimes: $0.cookingTimes.map{CookingTime(
                time: $0.time,
                timeDefStart: $0.timeDefStart,
                timeDefEnd: $0.timeDefEnd
            )}
        )}
        let url = self.url != nil ? URL(string: self.url!) : nil
        
        return Recipe(name: self.name, location: self.location, url: url, image: self.image, ingredients: ingredients, method: method)
    }
}

class RealmIngredient: Object, Decodable {
    @Persisted var text: String
    @Persisted var isDone: Bool
    
    convenience init(text: String, isDone: Bool){
        self.init()
        self.text = text
        self.isDone = isDone
    }
}

class RealmStep: Object, Decodable {
    @Persisted var text: String
    @Persisted var isDone: Bool
    @Persisted var cookingTimes: List<RealmCookingTime>
    
    convenience init(text: String, isDone: Bool, cookingTimes: [CookingTime]){
        self.init()
        self.text = text
        self.isDone = isDone
        
        self.cookingTimes = List<RealmCookingTime>()
        let realmCookingTimes = cookingTimes.map{RealmCookingTime(time: $0.time, timeDefStart: $0.timeDefStart, timeDefEnd: $0.timeDefEnd)}
        self.cookingTimes.append(objectsIn: realmCookingTimes)
    }
}

class RealmCookingTime: Object, Decodable {
    @Persisted var time: Int
    @Persisted var timeDefStart: Int
    @Persisted var timeDefEnd: Int
    
    convenience init(time: Int, timeDefStart: Int, timeDefEnd: Int){
        self.init()
        self.time = time
        self.timeDefStart = timeDefStart
        self.timeDefEnd = timeDefEnd
    }
}
