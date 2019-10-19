//
//  Utilities.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/13.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import Foundation
import ARKit
import GameKit

//MARK:Enums
enum Category:Int{
    case player = 1
    case obstacle = 2
    case obstaclePass = 4
    case rushModeObstaclePass = 8
    case plane = 16
    case non = 128
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
    static let allCases: [PlayerTextureType] = [.none, .heart, .mud, .rubiks, .woodDie]
}

enum GameThemeType: String, Codable {
    case metallic = "metallic"
    case gold = "gold"
    case amber = "amber"
    case future = "future"
    static let allCases: [GameThemeType] = [.metallic, .gold, .amber, .future]
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
        node: SCNNode,
        categoryBitMask: Int,
        contactTestBitMask: Int,
        collisionBitMask: Int,
        wantConcavePolyhedron: Bool = false
    ) {
        physicsBody = SCNPhysicsBody(
            type: type,
            shape: wantConcavePolyhedron ?
                SCNPhysicsShape(node: node, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]) :
                SCNPhysicsShape(node: node))
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
        physicsBody = nil
        geometry = nil
        removeFromParentNode()
    }
    
    func getRoot(in sceneView: ARSCNView) -> SCNNode {
        return getRootHelper(root: sceneView.scene.rootNode, current: self)
    }
    
    private func getRootHelper(root: SCNNode, current: SCNNode) -> SCNNode {
        if current.parent == nil || current.parent == root {
            return current
        } else {
            return getRootHelper(root: root, current: current.parent!)
        }
    }
}

extension SCNVector3 {
    static let zero = SCNVector3(0, 0, 0)
    static let one = SCNVector3(1, 1, 1)
}

extension Float {
    func roundedToTenth() -> Float{
        var value = self
        value *= 100
        return roundf(value) / 100
    }
}

extension Array {
    public init(count: Int, elementCreator: @autoclosure () -> Element) {
        self = (0 ..< count).map { _ in elementCreator() }
    }
}

extension UIFont {
    static func getCustomeSystemAdjustedFont(withSize size: Int = 24, adjustSizeAccordingToSystem: Bool = true) -> UIFont{
        guard let font = UIFont(name: "DIN Condensed Bold", size: CGFloat(size)) else {
            print("font invalide")
            return UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: CGFloat(size)))
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

//easy way to show alert
extension UIViewController {
    
    func showAlert(title: String,
                   message: String,
                   buttonTitle: String = "OK",
                   showCancel: Bool = false,
                   buttonHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: buttonHandler))
        if showCancel {
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
               
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
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


//MARK: Global functions
func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

//allow basic calculation between 2 vector3
func +(left:SCNVector3,right:SCNVector3)->SCNVector3{
    return SCNVector3(left.x+right.x,left.y+right.y,left.z+right.z)
}

func /(left:SCNVector3,right:Float)->SCNVector3{
    return SCNVector3(left.x/right, left.y/right, left.z/right)
}

func ==(left:SCNVector3,right:SCNVector3)->Bool{
    return (left.x == right.x && left.y == right.y && left.z == right.z)
}

func updatePositionAndOrientationOf(_ node: SCNNode, withPosition position: SCNVector3, relativeTo referenceNode: SCNNode) {
    let referenceNodeTransform = matrix_float4x4(referenceNode.transform)

    // Setup a translation matrix with the desired position
    var translationMatrix = matrix_identity_float4x4
    translationMatrix.columns.3.x = position.x
    translationMatrix.columns.3.y = position.y
    translationMatrix.columns.3.z = position.z

    // Combine the configured translation matrix with the referenceNode's transform to get the desired position AND orientation
    let updatedTransform = matrix_multiply(referenceNodeTransform, translationMatrix)
    node.transform = SCNMatrix4(updatedTransform)
}

func sendScoreToGameCenter(score: Int) {
    // Submit score to GC leaderboard
    let bestScoreInt = GKScore(leaderboardIdentifier: leaderBoardID)
    bestScoreInt.value = Int64(score)
    GKScore.report([bestScoreInt]) { (error) in
        if error != nil {
            print(error!.localizedDescription)
        } else {
            print("Best Score submitted to your Leaderboard!")
        }
    }
}


