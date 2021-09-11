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
    
    init(name: String?, location: String?, url: URL, image: Data?, ingredients: [Ingredient], method: [Step]){
        self.name = name ?? "Unknown"
        self.location = location ?? "Unknown Location"
        self.url = url.absoluteString
        do {
            self.ingredients = try List<RealmIngredient>(from: ingredients)
            self.method = try List<RealmStep>(from: method)
        } catch {
            print(error.localizedDescription)
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
    
    init(text: String, isDone: Bool){
        self.text = text
        self.isDone = isDone
    }
}

class RealmStep: Object, Decodable {
    @Persisted var text: String
    @Persisted var isDone: Bool
    @Persisted var cookingTimes: List<RealmCookingTime>
    
    init(text: String, isDone: Bool, cookingTimes: [CookingTime]){
        self.text = text
        self.isDone = isDone
        do {
            self.cookingTimes = try List<RealmCookingTime>(from: cookingTimes)
        } catch {
            print(error.localizedDescription)
        }
    }
}

class RealmCookingTime: Object, Decodable {
    @Persisted var time: Int
    @Persisted var timeDefStart: Int
    @Persisted var timeDefEnd: Int
    
    init(time: Int, timeDefStart: Int, timeDefEnd: Int){
        self.time = time
        self.timeDefStart = timeDefStart
        self.timeDefEnd = timeDefEnd
    }
}
