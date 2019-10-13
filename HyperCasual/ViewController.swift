//
//  ViewController.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/13.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var sceneView:ARSCNView = ARSCNView()
    
    var player:SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUPSceneView()
        setupCamera()
        setUpPlayer()
        sceneView.delegate = self
        //sceneView.debugOptions = [.showPhysicsShapes]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureARSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let currentFrame = sceneView.session.currentFrame{
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.5
            player.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        }
    }
}

//MARK: viewDidLoad set up functions
extension ViewController {
    func setUPSceneView(){
        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ]
        )
    }
    
    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        
        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    func configureARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.wantsHDREnvironmentTextures = true
        sceneView.session.run(configuration)
    }
    
    //MARK: player set up
    func setUpPlayer() {
        setUpPlayerShape()
        setUpPlayerPhysics()
    }
    
    func setUpPlayerShape() {
        player = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01))
        player.name = "player"
        let reflectiveMaterial = SCNMaterial()
        reflectiveMaterial.lightingModel = .physicallyBased
        reflectiveMaterial.metalness.contents = 1.0
        reflectiveMaterial.roughness.contents = 0
        player.geometry?.firstMaterial = reflectiveMaterial
        sceneView.scene.rootNode.addChildNode(player)
    }
    
    func setUpPlayerPhysics() {
        player.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01), options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]))
        player.physicsBody?.categoryBitMask = catagory.player.rawValue
        player.physicsBody?.isAffectedByGravity = false
//        player.physicsBody?.contactTestBitMask = catagory.upperChecker.rawValue | catagory.lowerChecher.rawValue
//        player.physicsBody?.collisionBitMask = catagory.goal.rawValue
    }
}
