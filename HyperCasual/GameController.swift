//
//  GameController.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/14.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import Foundation

class GameController: Codable {
    
    static var shared = GameController()
    
    var isFirstTimePlay = true {
           didSet{
               save()
           }
       }
    
    private init(){}
    
    //MARK:Values
    var playerTexture = PlayerTextureType.heart {
        didSet{
            save()
        }
    }
    
    var gameTheme = GameThemeType.metallic {
           didSet{
               save()
           }
       }
    
    var playerShape = PlayerShapeType.cube {
           didSet{
               save()
           }
       }
    
    var playerTrail = PlayerTrailType.none {
           didSet{
               save()
           }
       }
    
    func save(){
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        guard let data = try? encoder.encode(self)
            else { fatalError("can't encode to PropertyList") }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}



