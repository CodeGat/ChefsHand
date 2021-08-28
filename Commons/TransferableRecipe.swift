//
//  TransferableRecipe.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 22/8/21.
//

import Foundation
import CoreData
import SwiftSoup

public class Recipe: NSObject, Codable {
    var name: String
    var location: String?
    var image: Data?
    var ingredients: [Ingredient]
    var method: [Step]
    
    private var url: URL
    
    init(url: URL) throws {
        self.url = url
        do {
            //MARK: Maybe make a typealiased tuple of (String, String, Data, [Ingredient], [Step])?
            let info: RecipeInfo = try getRecipeData(using: url)
            self.name = info.name
            self.location = info.location
            self.image = info.image
            self.ingredients = info.ingredients
            self.method = info.method
        } catch {
            throw error
        }
    }

    init(name: String, location: String?, image: Data?, ingredients: [Ingredient], method: [Step]){
        self.name = name
        self.location = location
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

protocol NSManagedObjectConvertable: AnyObject {
    func convert(given context: NSManagedObjectContext) -> NSManagedObject
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

extension Recipe {
    struct RecipeInfo {
        var name: String
        var location: String
        var image: Data?
        var ingredients: [Ingredient]
        var method: [Step]
    }
    
    private func getRecipeData(using url: URL) throws -> RecipeInfo {
        guard let host = url.host else {
            throw RecipeError.unknownHostError
        }
        do {
            switch(host){
            case "taste.com.au":
                return try generateTasteRecipe(using: url, from: host)
            default:
                return try generateGenericRecipe(using: url, from: host)
            }
        } catch {
            throw error
        }
    }
    
    private func getCookingTimes(in instruction: String) -> [CookingTime] {
        var cookingTimes: [CookingTime] = []
        
        do {
            let regex = try NSRegularExpression(pattern: #"[0-9]+ ?(h(ou)?r|min(ute)?|sec(ond)?)s?"#, options: []) //TODO: only integers
            let matches = regex.matches(in: instruction, options: [], range: NSRange(location: 0, length: instruction.count))
            
            for match in matches {
                let matchRange: NSRange = match.range(at: 0) // get the first match (the largest one)
                if let substringRange: Range = Range(matchRange, in: instruction) {
                    let cookingTimeString: String = String(instruction[substringRange])
                    let cookingTime: Int = getCookingTimeInSeconds(of: cookingTimeString)
                    let cookingTimer = CookingTime(time: cookingTime, timeDefStart: matchRange.lowerBound, timeDefEnd: matchRange.upperBound)
                    cookingTimes.append(cookingTimer)
                }
            }
        } catch {
            print(error)
        }
        
        return cookingTimes
    }
    
    func getCookingTimeInSeconds(of timeString: String) -> Int {
        let timeComponents: [String] = timeString.components(separatedBy: " ")
        let time: Int = Int(timeComponents[0])!
        
        switch timeComponents[1] {
        case let unit where unit.contains("h"):
            return time * 60 * 60
        case let unit where unit.contains("m"):
            return time * 60
        default:
            return time
        }
    }
    
    private func generateTasteRecipe(using url: URL, from host: String) throws -> RecipeInfo {
        struct TasteRecipe: Decodable {
            var recipeIngredients: [String]
            var recipeInstructions: [String]
        }
        
        do {
            let html: String = try String(contentsOf: url, encoding: .ascii)
            let decoder = JSONDecoder()
            let doc: Document = try SwiftSoup.parse(html)
            
            let name: String = try doc.select("title").first()?.text() ?? "Unknown"
            
            let recipeHtmlElement: Element = try doc.select("script[data-schema-entity=recipe]").first()!
            let recipeElementString: String = recipeHtmlElement.data()
            let recipeData: Data = recipeElementString.data(using: .utf8)!
            let tasteRecipe = try decoder.decode(TasteRecipe.self, from: recipeData)
            
            let tasteRecipeIngredients: [Ingredient] = tasteRecipe.recipeIngredients.map{Ingredient(text: $0, isDone: false)}
            
            let tasteRecipeSteps: [Step] = tasteRecipe.recipeInstructions.map{Step(text: $0, isDone: false, cookingTimes: getCookingTimes(in: $0))}
            
            return RecipeInfo(name: name, location: host, image: nil, ingredients: tasteRecipeIngredients, method: tasteRecipeSteps)
        } catch {
            throw RecipeError.tasteRecipeUnconvertableError
        }
    }
    
    private func generateGenericRecipe(using url: URL, from host: String) throws -> RecipeInfo {
        do {
            let html: String = try String(contentsOf: url, encoding: .ascii)
            let doc: Document = try SwiftSoup.parse(html)
            
            let name: String = try doc.select("title").first()?.text() ?? "Unknown"
            
            return RecipeInfo(name: name, location: host, image: nil, ingredients: [], method: [])
            return RecipeInfo(name: <#T##String#>, location: <#T##String#>, image: <#T##Data?#>, ingredients: <#T##[Ingredient]#>, method: <#T##[Step]#>)
        } catch {
            throw RecipeError.genericRecipeUnconvertableError(host: host)
        }
    }
}

enum RecipeError: Error {
    case unknownHostError
    case genericRecipeUnconvertableError(host: String)
    case tasteRecipeUnconvertableError
}

extension RecipeError: CustomStringConvertible {
    var description: String {
        switch self {
        case .unknownHostError:
            return "Host was not given or valid"
        case .genericRecipeUnconvertableError(let host):
            return "this generic recipe from \(host) couldn't be converted into an Apple Watch format"
        case .tasteRecipeUnconvertableError:
            return "This recipe from taste.com.au couldn't be converted into an Apple Watch format"
        }
    }
}
