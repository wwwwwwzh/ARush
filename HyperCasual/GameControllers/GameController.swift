//
//  GameController.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/14.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import Foundation

enum GameControllerKeys: String {
    case lastScore = "lastScore"
    case highScore = "highScore"
    case isFirstTime = "isFirstTime"
    case playerTexture = "playerTexture!"
    case gameTheme = "gameTheme"
    case playerTail = "playerTail"
    case hasRated = "hasRated"
    case metals = "metals"
    case ownedPlayers = "ownedPlayers"
}

class GameController: Codable {
    
    static let shared = GameController()
    
    private init() {}
    
    var isFirstTimePlay = true {
           didSet{
               UserDefaults.standard.set(GameController.shared.isFirstTimePlay, forKey: GameControllerKeys.isFirstTime.rawValue)
           }
       }
    
    var hasRated = false {
        didSet{
            UserDefaults.standard.set(GameController.shared.hasRated, forKey: GameControllerKeys.hasRated.rawValue)
        }
    }
    
    var lastScore = 0 {
        didSet{
            print(GameController.shared.lastScore)
            UserDefaults.standard.set(GameController.shared.lastScore, forKey: GameControllerKeys.lastScore.rawValue)
        }
    }
    
    var highScore = 0 {
        didSet{
            UserDefaults.standard.set(GameController.shared.highScore, forKey: GameControllerKeys.highScore.rawValue)
        }
    }
    
    var metals = 0 {
        didSet{
            UserDefaults.standard.set(GameController.shared.metals, forKey: GameControllerKeys.metals.rawValue)
        }
    }
    
    var ownedPlayers = [PlayerTextureType.none] {
        didSet{
            let rawValues = GameController.shared.ownedPlayers.map { (pt) -> String in
                return pt.rawValue
            }
            UserDefaults.standard.set(rawValues, forKey: GameControllerKeys.ownedPlayers.rawValue)
        }
    }
        
    var playerTexture = PlayerTextureType.none {
        didSet{
            UserDefaults.standard.set(GameController.shared.playerTexture.rawValue, forKey: GameControllerKeys.playerTexture.rawValue)
        }
    }
    
    var gameTheme = GameThemeType.metallic {
           didSet{
            UserDefaults.standard.set(GameController.shared.gameTheme.rawValue, forKey: GameControllerKeys.gameTheme.rawValue)
           }
       }
        
    var playerTrail = PlayerTrailType.none {
           didSet{
            UserDefaults.standard.set(GameController.shared.playerTrail.rawValue, forKey: GameControllerKeys.playerTail.rawValue)
           }
       }
        
    func toString() {
        print("Player texture: \(playerTexture). Game theme: \(gameTheme), player trial: \(playerTrail). Last score: \(lastScore)")
    }
}



