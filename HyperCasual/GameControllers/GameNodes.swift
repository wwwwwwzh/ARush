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
enum Direction: Int {
    case wall = 0
    case up = 5
    case down = 6
    case left = 3
    case right = 2
    case rotate = 7
    case end = 1
}
extension GameNodes {
    
}

//MARK: - Obstable generaters
class GameNodes {
    private static func getGoThrough(randomizeLength: Bool = false, rotate: Bool = true, rotate45Degree: Bool = false) -> SCNNode {
        //get the open width
        let openWidth = GameFlowController.shared.openWidth * 1.1
        
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
        if rotate {
            node.runAction(SCNAction.rotateBy(x: 0, y: 0, z: rotate45Degree ? CGFloat.pi / 4 : CGFloat.pi * CGFloat.random(in: 0...0.5), duration: 0))
        }
                
        GameFlowController.shared.currentObstacleLength = Double(length)
        GameFlowController.shared.maxSpeed = rotate ? 0.2 : 0.3
                
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
    
    private static func getDoor(isHorizontal: Bool? = nil, length: CGFloat = obstacleWidth, single: Bool = false, direction: Direction? = nil) -> SCNNode {
        let openWidth = GameFlowController.shared.openWidth
        let height = obstacleWidth * 2 + openWidth
        ///the parent node at top of node hierachy
        let node = SCNNode()

        let nodes = [SCNNode](count: 2, elementCreator: SCNNode(geometry: SCNBox(width: obstacleWidth, height: height, length: length, chamferRadius: obstacleWidth / 4)))
        
        let innerOffset = height / 2 - obstacleWidth * 1.5
        let outerOffset = innerOffset + obstacleWidth
        
        //make positioning random
        var seed = Int.random(in: 1...6)
        if let direction = direction {
            seed = direction.rawValue
        }
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
        let lever = SCNNode(geometry: SCNCylinder(radius: 0.005, height: 0.3))
        let hammer = SCNNode(geometry: SCNCylinder(radius: 0.05, height: 0.15))
                
        //adjust transform
        node.runAction(SCNAction.group([SCNAction.move(by: SCNVector3(0, 0.25, 0), duration: 0), SCNAction.rotate(by: -CGFloat.pi / 2, around: SCNVector3(0, 0, 1), duration: 0)]))
        lever.position.y = -0.15
        hammer.position.y = -0.3
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
        
        let block = SCNNode(geometry: SCNBox(width: obstacleWidth, height: 0.3, length: obstacleWidth, chamferRadius: obstacleWidth / 4))
        
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
    
    private static func getRotatingBlock() -> SCNNode {
        let node = SCNNode()
        
        let size = CGFloat(GameFlowController.shared.maxPlayerXOffset) + playerBoxWidth / 2
        let block = SCNNode(geometry: SCNBox(width: size, height: size, length: size, chamferRadius: 0.01))
        
        let seed = Int.random(in: 1...4)
        
        let xOffset = GameFlowController.shared.maxPlayerXOffset
        let yOffset = GameFlowController.shared.maxPlayerYOffset
        var action = SCNAction()
        //actions
        let left = SCNAction.move(by: SCNVector3(-2 * xOffset, 0, 0), duration: 0.5)
        let right = SCNAction.move(by: SCNVector3(2 * xOffset, 0, 0), duration: 0.5)
        let up = SCNAction.move(by: SCNVector3(0, 2 * yOffset, 0), duration: 0.5)
        let down = SCNAction.move(by: SCNVector3(0, -2 * yOffset, 0), duration: 0.5)
        switch seed {
        case 1:
            node.moveByWithAction(SCNVector3(-xOffset, -yOffset, 0))
            action = SCNAction.repeatForever(SCNAction.sequence([up, right, down, left]))
        case 2:
            node.moveByWithAction(SCNVector3(-xOffset, yOffset, 0))
            action = SCNAction.repeatForever(SCNAction.sequence([right, down, left, up]))
        case 3:
            node.moveByWithAction(SCNVector3(xOffset, -yOffset, 0))
            action = SCNAction.repeatForever(SCNAction.sequence([left, up, right, down]))
        case 4:
            node.moveByWithAction(SCNVector3(xOffset, yOffset, 0))
            action = SCNAction.repeatForever(SCNAction.sequence([down, left, up, right]))
        default:
            node.moveByWithAction(SCNVector3(-xOffset, -yOffset, 0))
            action = SCNAction.repeatForever(SCNAction.sequence([up, right, down, left]))
        }
        node.runAction(action)
        
        GameFlowController.shared.currentObstacleLength = Double(size)
        GameFlowController.shared.maxSpeed = 0.2
        
        
        node.addChildNode(block)
        
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
        
        GameFlowController.shared.currentObstacleLength = Double(tunnelLength * 2)
        GameFlowController.shared.maxSpeed = 0.3
        
        return node
    }
    
    private static func getObstaclePass() -> SCNNode {
        let node = SCNNode(geometry: SCNBox(width: 0.4, height: 0.4, length: 0.01, chamferRadius: 0))
        node.position = SCNVector3(0, 0, -GameFlowController.shared.currentObstacleLength / 2)
        node.opacity = 0
        node.name = "pass"
        return node
    }
    
    //MARK: - Rush mode generator
    private static func getRushModeObstacle() -> SCNNode {
        ///the parent node at top of node hierachy
        let node = SCNNode()
        
        let blocks = [SCNNode](count: 4, elementCreator: SCNNode(geometry: SCNBox(width: obstacleWidth, height: obstacleWidth, length: obstacleWidth, chamferRadius: 0)))
        let offset = obstacleWidth / 2
        blocks[0].position = SCNVector3(offset, offset, 0)
        blocks[1].position = SCNVector3(offset, -offset, 0)
        blocks[2].position = SCNVector3(-offset, offset, 0)
        blocks[3].position = SCNVector3(-offset, -offset, 0)
        
        for i in 0...3 {
            if Bool.random() {
                node.addChildNode(blocks[i])
            }
        }
        //check if no child was added
        if node.childNodes.count == 0 {
            node.addChildNode(blocks[Int.random(in: 0...3)])
        }
        //check if no child was removed
        if node.childNodes.count == 4 {
            node.childNodes[Int.random(in: 0...3)].removeFromParentNode()
        }
                
        GameFlowController.shared.currentObstacleLength = Double(obstacleWidth)
        GameFlowController.shared.maxSpeed = 0.2
        
        return node
    }
    
    static func getWall() -> SCNNode {
        //get the open width
        let height = CGFloat(GameFlowController.shared.wallOffset * 2)
        
        let width: CGFloat = 1.5
        
        ///the parent node at top of node hierachy
        let node = SCNNode()
        
        //single wall
        let wallPlane = SCNPlane(width: width, height: height)
        //material
        wallPlane.firstMaterial?.diffuse.contents = UIImage(named: "Models.scnassets/wallImage.png")
        wallPlane.firstMaterial?.isDoubleSided = true
        let nodes = [SCNNode](count: 4, elementCreator: SCNNode(geometry: wallPlane))
        //rotate each wall
        let rightAngle = CGFloat.pi/2
        nodes[0].eulerAngles = SCNVector3(rightAngle,rightAngle,0)
        nodes[1].eulerAngles = SCNVector3(rightAngle,rightAngle,0)
        nodes[2].eulerAngles = SCNVector3(0,rightAngle,0)
        nodes[3].eulerAngles = SCNVector3(0,rightAngle,0)
        
        //position walls
        let positionOffset = GameFlowController.shared.wallOffset
        nodes[0].position = SCNVector3(0, positionOffset, 0)
        nodes[1].position = SCNVector3(0, -positionOffset, 0)
        nodes[2].position = SCNVector3(positionOffset, 0, 0)
        nodes[3].position = SCNVector3(-positionOffset, 0, 0)
        
        node.addChildNodes(nodes)
        
        node.position.z = 0.5
        
        return node
    }
}


//MARK:Main function
extension GameNodes {
    /**
     Get random obstacles for casual mode
     */
    static func getObstacle() -> SCNNode {
        let root = SCNNode()
        
        ///shape node
        var node: SCNNode!
        switch GameController.shared.gameMode {
        case .casual:
            node = getShape()
        case .rush:
            node = getRushModeObstacle()
        }
        //play tutorial
        if GameController.shared.isFirstTimePlay {
            if GameFlowController.shared.directions.count > 0 {
                let direction = GameFlowController.shared.directions[0]
                node = getDoor(direction: direction)
                if direction == .rotate {
                    node = getGoThrough(randomizeLength: false, rotate: true, rotate45Degree: true)
                }
                GameFlowController.shared.currentDirection = direction
                if direction == .wall {
                    node = SCNNode()
                }
            }
        }
        let material = Materials.getMaterial()
        node.assignMaterial(material)
        node.opacity = 0
        node.name = "obstacle"
        
        node.runAction(SCNAction.sequence([SCNAction.fadeIn(duration: 0.5), SCNAction.customAction(duration: 0, action: { (node, _) in
            //physics
            node.generatePhysicsBody(type: .static, node: node, categoryBitMask: Category.obstacle.rawValue, contactTestBitMask: Category.player.rawValue, collisionBitMask: Category.player.rawValue, wantConcavePolyhedron: true)
        })]))
        
        root.addChildNode(node)
        
        ///pass node
        let pass = getObstaclePass()
        pass.generatePhysicsBody(type: .static, node: pass, categoryBitMask: Category.obstaclePass.rawValue, contactTestBitMask: Category.player.rawValue, collisionBitMask: Category.non.rawValue, wantConcavePolyhedron: true)
        
        ///wall effect
        let wall = getWall()
        root.addChildNode(wall)
        
        root.addChildNode(pass)
        //position
        root.moveByWithAction(SCNVector3(0, 0, -1))
        
        //animation
        var moveVector: SCNVector3!
        switch GameController.shared.gameMode {
        case .casual:
            moveVector = SCNVector3(x: 0, y: 0, z: Float(GameFlowController.shared.currentObstacleLifetimeMoveDistance))
        case .rush:
            moveVector = SCNVector3(x: 0, y: 0, z: Float(GameFlowController.shared.currentObstacleLifetimeMoveDistance))
        }
        let moveAction = SCNAction.sequence(
            [SCNAction.move(
                by: moveVector,
                duration: GameFlowController.shared.currentObstacleLifetimeMoveDistance / GameFlowController.shared.speed),
             SCNAction.customAction(duration: 0, action: { (node, _) in
                node.removeEverything()
             })
        ])
        let wallFadeInAndOut = SCNAction.sequence([SCNAction.fadeIn(duration: 0.5), SCNAction.wait(duration: GameFlowController.shared.currentDirection == .wall ? 3 : 1), SCNAction.fadeOut(duration: 0.5)])
        node.runAction(moveAction)
        pass.runAction(moveAction)
        wall.runAction(wallFadeInAndOut)
        
        return root
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
        player.generatePhysicsBody(type: .dynamic, categoryBitMask: Category.non.rawValue, contactTestBitMask: Category.obstacle.rawValue | Category.obstaclePass.rawValue, collisionBitMask: Category.obstacle.rawValue, shape: SCNBox(width: playerBoxWidth, height: playerBoxWidth, length: playerBoxWidth, chamferRadius: 0))
        return player
    }
    
    
    
    static func getMenuViewObstacle() -> [SCNNode] {
        let currentTheme = GameController.shared.gameTheme
        let nodes = GameThemeType.allCases.map { (theme) -> SCNNode in
            GameController.shared.gameTheme = theme
            let node = getGoThrough(randomizeLength: false, rotate: false)
            node.assignMaterial(Materials.getMaterial())
            node.scale = SCNVector3(1.5, 1.5, 1.5)
            return node
        }
        GameController.shared.gameTheme = currentTheme
        return nodes
    }
    
    static func getScoreLabels() -> SCNNode {
        let scene = SCNScene(named: "Models.scnassets/BasicLevel.scn")!
        let root = scene.rootNode.childNode(withName: "ScoreNode", recursively: false)!
        root.assignMaterial(Materials.getMaterial())
        (root.childNode(withName: "Casual High", recursively: false)!.geometry! as! SCNText).string = "\(localizedString("Casual High: "))\(GameController.shared.highScoreCasualMode)"
        (root.childNode(withName: "Rush High", recursively: false)!.geometry! as! SCNText).string = "\(localizedString("Rush High: "))\(GameController.shared.highScoreRushMode)"
        
        return root
    }
        
    //MARK: Random shape generator
    private static func getShape() -> SCNNode {
        let level = GameFlowController.shared.level
        let seed = Int.random(in: 1...100)
        switch level {
        case 0:
            switch seed {
            case 1...30:
                return getGoThrough()
            case 31...40:
                return getSwings()
            case 41...70:
                return getDoor()
            case 71...90:
                return getRotatingBlock()
            default:
                return getRandomizedGoThrough()
            }
        case 1:
            switch seed {
            case 1...20:
                return getRandomizedGoThrough(randomizeLength: true)
            case 21...30:
                return getSwings()
            case 31...55:
                return getGoThrough(randomizeLength: true)
            case 56...70:
                return getTunnel()
            case 71...85:
                return getRotatingBlock()
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
            case 51...65:
                return getGoThrough(randomizeLength: true)
            case 66...75:
                return getTunnel()
            case 76...90:
                return getRotatingBlock()
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
            case 61...75:
                return getTunnel()
            case 76...90:
                return getRotatingBlock()
            default:
                return getDoor()
            }
        case 4:
            switch seed {
            case 1...20:
                return getRandomizedGoThrough(randomizeLength: true)
            case 21...30:
                return getSwings()
            case 31...40:
                return getMovingBlocks()
            case 41...70:
                return getGoThrough(randomizeLength: true)
            case 71...85:
                return getTunnel()
            case 86...95:
                return getRotatingBlock()
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
            case 51...70:
                return getTunnel()
            case 71...85:
                return getRotatingBlock()
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
    var all: [SCNNode] {
        return [metalCube, heart, mud, rubiks, woodDie]
    }
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
            if let scene = SCNScene(named: "Models.scnassets/Dice/Models/Rubiks.scn") {
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
            let shape = SCNBox(width: playerBoxWidth, height: playerBoxWidth, length: playerBoxWidth, chamferRadius: 0.01)
            player = SCNNode(geometry: shape)
            
            //set material
            let material = Materials.getMaterial()
            player.geometry?.firstMaterial = material
            
            return player
        }
    }
}
