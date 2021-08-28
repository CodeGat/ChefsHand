//
//  URLRecipe.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 28/8/21.
//

import Foundation
import SwiftSoup

class URLRecipe: Recipe {
    init(url: URL) throws {
        do {
            //MARK: Maybe make a typealiased tuple of (String, String, Data, [Ingredient], [Step])?
            let info: RecipeInfo = try getRecipeData(using: url)
            super.init(name: info.name, location: info.location, url: url, image: info.image, ingredients: info.ingredients, method: info.method)
        } catch {
            throw error
        }
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
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
