//
//  GameController.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/14.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import Foundation
import SceneKit

enum GameControllerKeys: String {
    case highScoreRushMode = "highScoreRushMode"
    case highScoreCasualMode = "highScoreCasualMode"
    case timesOfPlay = "timesOfPlay"
    case isFirstTime = "isFirstTimeajknasasdasdasm"
    case playerTexture = "playerTexture!"
    case gameTheme = "gameTheme"
    case playerTail = "playerTail"
    case hasRated = "hasRated"
    case metals = "metals"
    case ownedPlayers = "ownedPlayers"
    case isSoundOn = "isSoundOn"
    case isHapticOn = "isHapticOn"
}

enum GameMode: String {
    case casual = "casual"
    case rush = "rush"
}

class GameController {
    
    static let shared = GameController()
    
    private init() {}
    
    var gameMode = GameMode.casual
    
    var isFirstTimePlay = true {
           didSet{
               UserDefaults.standard.set(GameController.shared.isFirstTimePlay, forKey: GameControllerKeys.isFirstTime.rawValue)
           }
    }
    
    var timesOfPlay = 0 {
        didSet{
            UserDefaults.standard.set(GameController.shared.timesOfPlay, forKey: GameControllerKeys.timesOfPlay.rawValue)
        }
    }
    
    var hasRated = false {
        didSet{
            UserDefaults.standard.set(GameController.shared.hasRated, forKey: GameControllerKeys.hasRated.rawValue)
        }
    }
    
    var isSoundOn = true {
        didSet{
            UserDefaults.standard.set(GameController.shared.isSoundOn, forKey: GameControllerKeys.isSoundOn.rawValue)
        }
    }
    
    var isHapticOn = true {
        didSet{
            UserDefaults.standard.set(GameController.shared.isHapticOn, forKey: GameControllerKeys.isHapticOn.rawValue)
        }
    }
    
    var highScoreRushMode = 0 {
        didSet{
            UserDefaults.standard.set(GameController.shared.highScoreRushMode, forKey: GameControllerKeys.highScoreRushMode.rawValue)
        }
    }
    
    var highScoreCasualMode = 0 {
        didSet{
            UserDefaults.standard.set(GameController.shared.highScoreCasualMode, forKey: GameControllerKeys.highScoreCasualMode.rawValue)
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
            print(GameController.shared.gameTheme)
            UserDefaults.standard.set(GameController.shared.gameTheme.rawValue, forKey: GameControllerKeys.gameTheme.rawValue)
           }
       }
        
    var playerTrail = PlayerTrailType.none {
           didSet{
            UserDefaults.standard.set(GameController.shared.playerTrail.rawValue, forKey: GameControllerKeys.playerTail.rawValue)
           }
       }
        
    func toString() {
        
    }
}



