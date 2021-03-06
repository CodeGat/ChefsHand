//
//  TransferableRecipe.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 22/8/21.
//

import Foundation

public class Recipe: NSObject, Codable {
    var name: String = "Unknown"
    var location: String?
    var url: URL?
    var image: Data?
    var ingredients: [Ingredient] = []
    var method: [Step] = []

    init(name: String, location: String?, url: URL?, image: Data?, ingredients: [Ingredient], method: [Step]){
        self.name = name
        self.location = location
        self.url = url
        self.image = image
        self.ingredients = ingredients
        self.method = method
    }
}

public class Ingredient: NSObject, Codable {
    var text: String
    var isDone: Bool
    
    init(text: String, isDone: Bool){
        self.text = text
        self.isDone = isDone
    }
}

public class Step: NSObject, Codable {
    var text: String
    var isDone: Bool
    var cookingTimes: [CookingTime]
    
    init(text: String, isDone: Bool, cookingTimes: [CookingTime]){
        self.text = text
        self.isDone = isDone
        self.cookingTimes = cookingTimes
    }
}

public class CookingTime: NSObject, Codable {
    var time: Int
    var timeDefStart: Int
    var timeDefEnd: Int
    
    init(time: Int, timeDefStart: Int, timeDefEnd: Int){
        self.time = time
        self.timeDefStart = timeDefStart
        self.timeDefEnd = timeDefEnd
    }
}

protocol RecipeConvertable: AnyObject {
    func convertToTransferrableRecipe() throws -> Recipe
}

protocol DatabaseObjectEncodable: AnyObject {
    associatedtype DBObject
    func dbEncode() -> DBObject
}

protocol DatabaseObjectDecodable: AnyObject {
    func dbDecode() -> Recipe
}

protocol UserDefaultSavable: AnyObject {
    func getRecipe() -> Recipe?
    func setRecipe(givenData data: Any)
    func setRecipe(givenRecipe recipe: Recipe)
    func storeRecipeChanges()
    func setRecipeIngredientIsDone(at rowIndex: Int, to value: Bool)
    func setRecipeStepIsDone(at rowIndex: Int, to value: Bool)
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
