//
//  Constants.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/14.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import Foundation
import SceneKit

let gravityY = Float(-3)

let playerBoxWidth = CGFloat(0.08)

let playerInitialDistance:Float = 0.4

let playerMaxDistanceOffset:Float = 0.2

let initialOpenWidth = playerBoxWidth * 1.5

let initialObstacleDistance = 0.4

let maxObstacleDistance = 1.0

let obstacleWidth = playerBoxWidth

let initialObstacleSpeed = CGFloat(0.2)

let defaultMaxObstacleSpeed = 0.5

let timerAccuracy = 0.1

let storageKey = "Stanford"

let leaderBoardID = "com.illumination.hypercasual.highscore"
let leaderBoardIDRushMode = "com.illumination.hypercasual.highscoreRushMode"

let TIMES_OF_PLAY_FOR_RATING_REQUEST = 5
