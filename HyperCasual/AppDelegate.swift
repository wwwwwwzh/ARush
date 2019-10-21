//
//  AppDelegate.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/13.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let standard = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //decode game controller storage data from userdefault.standard
        readGameController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MenuViewController()
        window?.makeKeyAndVisible()
        return true
    }
    
    private func readGameController() {
        if isKeyPresentInUserDefaults(key: GameControllerKeys.isFirstTime.rawValue) {
            GameController.shared.isFirstTimePlay = true
                //standard.bool(forKey: GameControllerKeys.isFirstTime.rawValue)
        }
        if isKeyPresentInUserDefaults(key: GameControllerKeys.hasRated.rawValue) {
            GameController.shared.hasRated = standard.bool(forKey: GameControllerKeys.hasRated.rawValue)
        }
        if isKeyPresentInUserDefaults(key: GameControllerKeys.playerTexture.rawValue) {
            GameController.shared.playerTexture = PlayerTextureType(rawValue: standard.string(forKey: GameControllerKeys.playerTexture.rawValue)!)!
        }
        if isKeyPresentInUserDefaults(key: GameControllerKeys.ownedPlayers.rawValue) {
            let inferred = standard.array(forKey: GameControllerKeys.ownedPlayers.rawValue)!.map { (str) -> PlayerTextureType in
                print(str)
                return PlayerTextureType(rawValue: str as! String)!
            }
            GameController.shared.ownedPlayers = inferred
        }
        if isKeyPresentInUserDefaults(key: GameControllerKeys.highScoreRushMode.rawValue) {
            GameController.shared.highScoreRushMode = standard.integer(forKey: GameControllerKeys.highScoreRushMode.rawValue)
        }
        if isKeyPresentInUserDefaults(key: GameControllerKeys.playerTail.rawValue) {
            GameController.shared.playerTrail = PlayerTrailType(rawValue: standard.string(forKey: GameControllerKeys.playerTail.rawValue)!)!
        }
        if isKeyPresentInUserDefaults(key: GameControllerKeys.highScoreCasualMode.rawValue) {
            GameController.shared.highScoreCasualMode = standard.integer(forKey: GameControllerKeys.highScoreCasualMode.rawValue)
        }
        if isKeyPresentInUserDefaults(key: GameControllerKeys.metals.rawValue) {
            GameController.shared.metals = standard.integer(forKey: GameControllerKeys.metals.rawValue)
        }
        if isKeyPresentInUserDefaults(key: GameControllerKeys.gameTheme.rawValue) {
            GameController.shared.gameTheme = GameThemeType(rawValue: standard.string(forKey: GameControllerKeys.gameTheme.rawValue)!)!
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}

