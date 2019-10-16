//
//  Utilities.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/13.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import Foundation
import SceneKit

//MARK:Enums
enum Category:Int{
    case player = 1
    case obstacle = 2
    case plane = 4
    case non = 1080
}

enum ObstacleIntervals: Double {
    case normal = 4.0
    
}

//MARK: Game settings enum
enum PlayerTextureType: String, Codable {
    case none = "none"
    case heart = "heart"
    case mud = "mud"
    case rubiks = "rubiks"
    case woodDie = "woodDie"
}

enum GameThemeType: String, Codable {
    case metallic = "metallic"
}

enum PlayerShapeType: String, Codable {
    case cube = "cube"
}

enum PlayerTrailType: String, Codable {
    case none = "none"
}

//MARK:SCNNode extension
extension SCNNode {
    
    /**
    Appends the nodes to the receiver’s childNodes array.
    - parameter nodes: nodes to be appended
    */
    func addChildNodes(_ nodes: [SCNNode]) {
        nodes.forEach { (node) in
            addChildNode(node)
        }
    }
    
    /**
    **Recursively** Add material to the node's all first children
    - parameter material: material to be used on all children
    */
    func assignMaterial(_ material: SCNMaterial) {
        if childNodes.count > 0 {
            childNodes.forEach { (node) in
                node.assignMaterial(material)
            }
        } else {
            geometry?.firstMaterial = material
            return
        }
    }
    
    func generatePhysicsBody(
        type: SCNPhysicsBodyType,
        categoryBitMask: Int,
        contactTestBitMask: Int,
        collisionBitMask: Int,
        wantConcavePolyhedron: Bool = false
    ) {
        physicsBody = SCNPhysicsBody(
            type: type,
            shape: wantConcavePolyhedron ?
                SCNPhysicsShape(node: self, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]) :
                SCNPhysicsShape(node: self))
        physicsBody?.categoryBitMask = categoryBitMask
        physicsBody?.isAffectedByGravity = false
        physicsBody?.contactTestBitMask = contactTestBitMask
        physicsBody?.collisionBitMask = collisionBitMask
    }
    
    func generatePhysicsBody(
        type: SCNPhysicsBodyType,
        categoryBitMask: Int,
        contactTestBitMask: Int,
        collisionBitMask: Int,
        shape: SCNGeometry
    ) {
        physicsBody = SCNPhysicsBody(type: type, shape: SCNPhysicsShape(geometry: shape, options: nil))
        physicsBody?.categoryBitMask = categoryBitMask
        physicsBody?.isAffectedByGravity = false
        physicsBody?.contactTestBitMask = contactTestBitMask
        physicsBody?.collisionBitMask = collisionBitMask
    }
    
    func moveByWithAction(_ vector: SCNVector3) {
        runAction(SCNAction.move(by: vector, duration: 0))
    }
    
    func removeEverything() {
        removeAllActions()
        removeAllAnimations()
        removeAllAudioPlayers()
        removeAllParticleSystems()
        removeFromParentNode()
    }
}

extension Array {
    public init(count: Int, elementCreator: @autoclosure () -> Element) {
        self = (0 ..< count).map { _ in elementCreator() }
    }
}

extension UIFont {
    static func getCustomeSystemAdjustedFont(withSize size: Int = 24, adjustSizeAccordingToSystem: Bool = true) -> UIFont{
        guard let font = UIFont(name: "SF Pro", size: CGFloat(size)) else {
            print("font invalide")
            return UIFont.systemFont(ofSize: CGFloat(size))
        }
        let cascadeList = [UIFontDescriptor(fontAttributes: [.name: "Chinese"])]
        let cascadeFontDescriptor = font.fontDescriptor.addingAttributes([.cascadeList:cascadeList])
        let cascadeFont = UIFont(descriptor: cascadeFontDescriptor, size: font.pointSize)
        if adjustSizeAccordingToSystem{
            return UIFontMetrics.default.scaledFont(for: cascadeFont)
        }else{
            return cascadeFont
        }
    }
}
/**
 get time since game start and translate to difficulty (0-16)
 **shoule divide by 4 to get game level**
 */
func translateTimeToDifficultyLevel(timeSinceStart: Int) -> Int {
    switch timeSinceStart {
    case 0..<20:
        return timeSinceStart/5
    case 20..<40:
        return Int(4 + Double(timeSinceStart-20)/10.0.rounded())
    case 40..<61:
        return Int(6 + Double(timeSinceStart-40)/7.0.rounded())
    case 61..<90:
        return Int(9 + Double(timeSinceStart-61)/10.0.rounded())
    case 90..<120:
        return Int(12 + Double(timeSinceStart-90)/6.0.rounded())
    case let time where time >= 120:
        return Int(17 + Double(timeSinceStart-120)/30.0.rounded())
    default:
        return 0
    }
}

