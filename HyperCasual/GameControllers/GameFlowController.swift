//
//  GameFlowController.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/15.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import Foundation
import SceneKit

class GameFlowController {
    static let shared = GameFlowController()
    
    var isPaused = false
    
    private var timer = Timer()
    
    var maxSpeed = defaultMaxObstacleSpeed
    
    var speed: Double {
        get {
            return min(Double(initialObstacleSpeed) + timeSinceStart * 0.005, maxSpeed)
        }
    }
    
    /**
     Time for next obstacle to initiate. **Get Only**
     */
    var instanciateInterval: Double {
        get {
            return (currentObstacleLength + obstacleDistance) / speed
        }
    }
    
    /**
     The distance the obstacle is going to move in 3D space. **Get Only**
     */
    var currentObstacleLifetimeMoveDistance: Double {
        get {
            return currentObstacleLength + 2
        }
    }
    
    var currentObstacleLength = 0.05
    
    /**
     Distance between two obstacles. Defaults to 1.0
     */
    var obstacleDistance: Double {
        get {
            if timeSinceStart > 30 {
                return maxObstacleDistance
            }
            return initialObstacleDistance + timeSinceStart * (maxObstacleDistance - initialObstacleDistance) / 30
        }
    }
    
    var level: Int {
        get {
            return translateTimeToDifficultyLevel(timeSinceStart: Int(timeSinceStart)) / 4
        }
    }
    
    var openWidth: CGFloat {
        get {
            if timeSinceStart > 30 {
                return 1.1 * playerBoxWidth
            }
            return initialOpenWidth - CGFloat(0.4 * Double(playerBoxWidth) / 30 * timeSinceStart)
        }
    }
    
    var maxPlayerXOffset: Float {
        get {
            let width = (openWidth + obstacleWidth * 2) / 2
            let offset = width - playerBoxWidth / 2
            return Float(offset * 1.1)
        }
    }
    
    var maxPlayerYOffset: Float {
        get {
            return maxPlayerXOffset
        }
    }
    
    var timeSinceStart = 0.0
    
    func setUpTimer() {
        timer.invalidate() // just in case this button is tapped multiple times
        timer = Timer.scheduledTimer(timeInterval: timerAccuracy, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction() {
        if (!isPaused) {
            timeSinceStart += timerAccuracy
        }
    }
    
    func reset() {
        GameFlowController.shared.timer.invalidate()
        GameFlowController.shared.timeSinceStart = 0
        GameFlowController.shared.maxSpeed = defaultMaxObstacleSpeed
        GameFlowController.shared.currentObstacleLength = 0.05
    }
}
