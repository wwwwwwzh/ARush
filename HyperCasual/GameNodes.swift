//
//  GameNodes.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/14.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import Foundation
import SceneKit

//MARK:Utilities
extension GameNodes {
}

//MARK:Obstable generaters
class GameNodes {
    private static func getGoThrough(randomizeLength: Bool = false) -> SCNNode {
        //get the open width
        let openWidth = GameFlowController.shared.openWidth
        
        let height = openWidth + obstacleWidth * 2
        
        let length = randomizeLength ? CGFloat.random(in: obstacleWidth...obstacleWidth * 5) : obstacleWidth
        
        ///the parent node at top of node hierachy
        let node = SCNNode()
        
        let nodes = [SCNNode](count: 4, elementCreator: SCNNode(geometry: SCNBox(width: obstacleWidth, height: height, length: length, chamferRadius: obstacleWidth / 4)))
        nodes[0].eulerAngles = SCNVector3(0,0,CGFloat.pi/2)
        nodes[1].eulerAngles = SCNVector3(0,0,CGFloat.pi/2)
        
        let positionOffset = (height - obstacleWidth) / 2
        nodes[0].position = SCNVector3(0, positionOffset, 0)
        nodes[1].position = SCNVector3(0, -positionOffset, 0)
        nodes[2].position = SCNVector3(positionOffset, 0, 0)
        nodes[3].position = SCNVector3(-positionOffset, 0, 0)
        
        node.addChildNodes(nodes)
        
        //random if use rotated
        if Bool.random() {
            node.runAction(SCNAction.rotateBy(x: 0, y: 0, z: CGFloat.pi / 4, duration: 0))
        }
        
        GameFlowController.shared.currentObstacleLength = Double(length)
        GameFlowController.shared.maxSpeed = defaultMaxObstacleSpeed
                
        return node
    }
    
    private static func getRandomizedGoThrough(randomizeLength: Bool = false) -> SCNNode {
        let node = SCNNode()
        
        let length = randomizeLength ? CGFloat.random(in: obstacleWidth...obstacleWidth * 5) : obstacleWidth
        
        node.addChildNode(getDoor(isHorizontal: true, length: length))
        node.addChildNode(getDoor(isHorizontal: false, length: length))
        
        GameFlowController.shared.currentObstacleLength = Double(length)
        GameFlowController.shared.maxSpeed = defaultMaxObstacleSpeed
        
        return node
    }
    
    private static func getDoor(isHorizontal: Bool? = nil, length: CGFloat = obstacleWidth, single: Bool = false) -> SCNNode {
        let openWidth = GameFlowController.shared.openWidth
        let height = obstacleWidth * 2 + openWidth
        ///the parent node at top of node hierachy
        let node = SCNNode()

        let nodes = [SCNNode](count: 2, elementCreator: SCNNode(geometry: SCNBox(width: obstacleWidth, height: height, length: length, chamferRadius: obstacleWidth / 4)))
        
        let innerOffset = height / 2 - obstacleWidth * 1.5
        let outerOffset = innerOffset + obstacleWidth
        
        //make positioning random
        var seed = Int.random(in: 1...6)
        if let isHorizontal = isHorizontal {
            if isHorizontal {
                seed = Int.random(in: 1...3)
            } else {
                seed = Int.random(in: 4...6)
            }
        }
        switch seed {
        case 1:
            nodes[0].position = SCNVector3(outerOffset, 0, 0)
            nodes[1].position = SCNVector3(-outerOffset, 0, 0)
        case 2:
            nodes[0].position = SCNVector3(outerOffset, 0, 0)
            nodes[1].position = SCNVector3(innerOffset, 0, 0)
        case 3:
            nodes[0].position = SCNVector3(-outerOffset, 0, 0)
            nodes[1].position = SCNVector3(-innerOffset, 0, 0)
        case 4:
            nodes[0].position = SCNVector3(0, outerOffset, 0)
            nodes[1].position = SCNVector3(0, -outerOffset, 0)
        case 5:
            nodes[0].position = SCNVector3(0, outerOffset, 0)
            nodes[1].position = SCNVector3(0, innerOffset, 0)
        case 6:
            nodes[0].position = SCNVector3(0, -outerOffset, 0)
            nodes[1].position = SCNVector3(0, -innerOffset, 0)
        default:
            nodes[0].position = SCNVector3(outerOffset, 0, 0)
            nodes[1].position = SCNVector3(innerOffset, 0, 0)
        }
        //rotate
        if seed >= 4 {
            nodes[0].eulerAngles = SCNVector3(0,0,CGFloat.pi/2)
            nodes[1].eulerAngles = SCNVector3(0,0,CGFloat.pi/2)
        }
        
        if single {
            let i = Int.random(in: 0...1)
            node.addChildNode(nodes[i])
        } else {
            node.addChildNodes(nodes)
        }
        
        GameFlowController.shared.currentObstacleLength = Double(length)
        GameFlowController.shared.maxSpeed = 0.6
        
        return node
    }
    
    private static func getSwings() -> SCNNode {
        ///the parent node at top of node hierachy
        let node = SCNNode()
        
        //get the components
        let lever = SCNNode(geometry: SCNCylinder(radius: 0.005, height: 0.25))
        let hammer = SCNNode(geometry: SCNCylinder(radius: 0.05, height: 0.15))
                
        //adjust transform
        node.runAction(SCNAction.group([SCNAction.move(by: SCNVector3(0, 0.25, 0), duration: 0), SCNAction.rotate(by: -CGFloat.pi / 2, around: SCNVector3(0, 0, 1), duration: 0)]))
        lever.position.y = -0.125
        hammer.position.y = -0.25
        hammer.eulerAngles.z = Float.pi / 2
        
        node.addChildNodes([lever, hammer])
                
        //animation
        let action = SCNAction.repeatForever(SCNAction.sequence([SCNAction.rotateBy(x: 0, y: 0, z: CGFloat.pi, duration: 1.6 - GameFlowController.shared.speed), SCNAction.rotateBy(x: 0, y: 0, z: -CGFloat.pi, duration: 1.6 - GameFlowController.shared.speed)]))
        node.runAction(action)
        
        GameFlowController.shared.currentObstacleLength = 0.5
        GameFlowController.shared.maxSpeed = 0.2
        
        return node
    }
    
    private static func getMovingBlocks() -> SCNNode {
        ///the parent node at top of node hierachy
        let node = SCNNode()
        
        let shape = SCNBox(width: obstacleWidth, height: 0.3, length: obstacleWidth, chamferRadius: obstacleWidth / 4)
        let block = SCNNode(geometry: shape)
        
        let seed = Bool.random()
        
        node.moveByWithAction(SCNVector3(seed ? -0.3 : 0.3, 0, 0))
        
        node.addChildNode(block)
                
        //animation
        let action = SCNAction.repeatForever(SCNAction.sequence([SCNAction.move(by: SCNVector3(seed ? 0.6 : -0.6, 0, 0), duration: 2 - GameFlowController.shared.speed), SCNAction.move(by: SCNVector3(seed ? -0.6 : 0.6, 0, 0), duration: 2 - GameFlowController.shared.speed)]))
        node.runAction(action)
        
        GameFlowController.shared.currentObstacleLength = 0.5
        GameFlowController.shared.maxSpeed = 0.2
        
        return node
    }
    
    private static func getTunnel() -> SCNNode {
        ///the parent node at top of node hierachy
        let node = SCNNode()
        
        let tunnelLength = CGFloat.random(in: 1...3)
        let obstacleDistance = CGFloat(0.5)
        let obstaclesCount = Int(ceil(tunnelLength / obstacleDistance))
        let isBodyHorizontal = Bool.random()
        let isObstaclesInsideTunnelHorizontal = !isBodyHorizontal
        
        //get the components
        let tunnelBody = getDoor(isHorizontal: isBodyHorizontal, length: tunnelLength)
        let obstaclesInside = [SCNNode](count: obstaclesCount, elementCreator: getDoor(isHorizontal: isObstaclesInsideTunnelHorizontal, single: true))
        
        //adjust positions
        tunnelBody.childNodes.forEach { (node) in
            node.position.z = -Float(tunnelLength / 2)
        }
        for i in 0..<obstaclesCount {
            obstaclesInside[i].childNodes.forEach { (node) in
                node.position.z = Float(-(obstacleWidth / 2)) - Float(obstacleDistance * CGFloat(i))
            }
        }
        
        node.addChildNode(tunnelBody)
        node.addChildNodes(obstaclesInside)
        
        GameFlowController.shared.currentObstacleLength = Double(tunnelLength)
        GameFlowController.shared.maxSpeed = 0.3
        
        return node
    }
}


//MARK:Main function
extension GameNodes {
    static func getObstacle() -> SCNNode {
        let node = getShape()
        let material = Materials.getMaterial()
        node.assignMaterial(material)
        return node
    }
    
    static func getPlayer() -> SCNNode {
        let player: SCNNode!
        switch GameController.shared.playerTexture {
        case .heart:
            player = PlayerModels.shared.heart
        case .mud:
            player = PlayerModels.shared.mud
        case .rubiks:
            player = PlayerModels.shared.rubiks
        case .woodDie:
            player = PlayerModels.shared.woodDie
        case .none:
            player = PlayerModels.shared.metalCube
        }
        //physics
        player.name = "player"
        player.childNode(withName: "Identity", recursively: false)?.scale = SCNVector3(playerBoxWidth, playerBoxWidth, playerBoxWidth)
        player.generatePhysicsBody(type: .dynamic, categoryBitMask: Category.non.rawValue, contactTestBitMask: Category.obstacle.rawValue, collisionBitMask: Category.obstacle.rawValue, shape: SCNBox(width: playerBoxWidth, height: playerBoxWidth, length: playerBoxWidth, chamferRadius: 0))
        return player
    }
    
    private static func getShape() -> SCNNode {
        let level = GameFlowController.shared.level
        let seed = Int.random(in: 1...100)
        switch level {
        case 0:
            switch seed {
            case 1...20:
                return getDoor()
            case 21...50:
                return getSwings()
            case 51...80:
                return getGoThrough()
            default:
                return getRandomizedGoThrough()
            }
        case 1:
            switch seed {
            case 1...20:
                return getRandomizedGoThrough(randomizeLength: true)
            case 21...30:
                return getSwings()
            case 31...40:
                return getMovingBlocks()
            case 41...60:
                return getGoThrough(randomizeLength: true)
            case 61...85:
                return getTunnel()
            default:
                return getDoor()
            }
        case 2:
            switch seed {
            case 1...30:
                return getRandomizedGoThrough(randomizeLength: true)
            case 31...40:
                return getSwings()
            case 41...50:
                return getMovingBlocks()
            case 51...70:
                return getGoThrough(randomizeLength: true)
            case 71...85:
                return getTunnel()
            default:
                return getDoor()
            }
        case 3:
            switch seed {
            case 1...20:
                return getRandomizedGoThrough(randomizeLength: true)
            case 21...30:
                return getSwings()
            case 31...40:
                return getMovingBlocks()
            case 41...60:
                return getGoThrough(randomizeLength: true)
            case 61...85:
                return getTunnel()
            default:
                return getDoor()
            }
        case 4:
            switch seed {
            case 1...20:
                return getRandomizedGoThrough(randomizeLength: true)
            case 21...40:
                return getSwings()
            case 41...60:
                return getMovingBlocks()
            case 61...80:
                return getGoThrough(randomizeLength: true)
            case 81...95:
                return getTunnel()
            default:
                return getDoor()
            }
        case let level where level > 4:
            switch seed {
            case 1...10:
                return getRandomizedGoThrough(randomizeLength: true)
            case 11...20:
                return getSwings()
            case 21...30:
                return getMovingBlocks()
            case 31...50:
                return getGoThrough(randomizeLength: true)
            case 51...80:
                return getTunnel()
            default:
                return getDoor()
            }
        default:
            return getDoor()
        }
    }
}

//MARK: PLayer Models
class PlayerModels {
    static let shared = PlayerModels()
    var heart: SCNNode {
        get {
            if let scene = SCNScene(named: "Models.scnassets/Dice/Models/Heart.scn") {
                let node = scene.rootNode.childNode(withName: "Cube", recursively: false)!
                return node
            }
            return metalCube
        }
    }
    var mud: SCNNode {
        get {
            if let scene = SCNScene(named: "Models.scnassets/Dice/Models/MudCube.scn") {
                let node = scene.rootNode.childNode(withName: "Cube", recursively: false)!
                return node
            }
            return metalCube
        }
    }
    var rubiks: SCNNode {
        get {
            if let scene = SCNScene(named: "Models.scnassets/Dice/Models/Rubikscube.scn") {
                return scene.rootNode.childNode(withName: "Cube", recursively: false)!
            }
            return metalCube
        }
    }
    var woodDie: SCNNode {
        get {
            if let scene = SCNScene(named: "Models.scnassets/Dice/Models/WoodDie.scn") {
                return scene.rootNode.childNode(withName: "Cube", recursively: false)!
            }
            return metalCube
        }
    }
    var metalCube: SCNNode {
        get {
            var player: SCNNode!
            //set shape
            var shape: SCNGeometry!
            switch GameController.shared.playerShape {
            case .cube:
                shape = SCNBox(width: playerBoxWidth, height: playerBoxWidth, length: playerBoxWidth, chamferRadius: 0.01)
            }
            player = SCNNode(geometry: shape)
            
            //set material
            let material = SCNMaterial()
            switch GameController.shared.gameTheme {
            case .metallic:
                material.lightingModel = .physicallyBased
                material.metalness.contents = 1.0
                material.roughness.contents = 0
            }
            player.geometry?.firstMaterial = material
            
            return player
        }
    }
}
