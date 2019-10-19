//
//  MainGameViewController.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/13.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AudioToolbox
import CoreMotion

class MainGameViewController: UIViewController {
    
    var onDoneBlock : (() -> Void)?
    
    var sceneView:ARSCNView = ARSCNView()
    
    let configuration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        if #available(iOS 13.0, *) {
            configuration.wantsHDREnvironmentTextures = true
        }
        configuration.planeDetection = [.horizontal]
        return configuration
    }()
    
    var player:SCNNode!
    
    var isPlayerDead = false
        
    var timer = Timer()
    
    var timePassed = 0.0
    
    var motionManager = CMMotionManager()
    
    var isPitchCorrect = false
    
    var shouldStartGame = false
    
    //UI
    var instructionLabel = InstructionOverlayView()
    
    var bottomNoticeLabel = BluredView()
    
    var startGameButton = BluredView()
    
    var replayButton = BluredView(icon: #imageLiteral(resourceName: "replay"))
    
    var scoreLabel = BluredView()
    
    var stopButton = BluredView(icon: #imageLiteral(resourceName: "stop"))
    
    var goBackButton = BluredView(icon: #imageLiteral(resourceName: "go-back-left-arrow"))
        
    //MARK:viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUPSceneView()
        setupCamera()
        
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.gravity.y = gravityY
        
        sceneView.debugOptions = [.showPhysicsShapes]
        //GameController.shared.playerTexture = .mud
        setUpMotionManager()
        
        setUPBottomLabel()
        setUpStartGameButton()
        setUpInstructionLabel()
        setUpScoreLabel()
        setUpReplayButton()
        setUpStopButton()
        setUpGoBackButton()
        
        player = GameNodes.getPlayer()
        sceneView.scene.rootNode.addChildNode(player)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureARSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        sceneView.session.pause()
        GameFlowController.shared.reset()
        sceneView.scene.rootNode.childNodes.forEach { (node) in
            node.removeEverything()
        }
    }
    
}

//MARK: viewDidLoad set up functions
extension MainGameViewController {
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
        camera.zNear = 0.05
    }
    
    
    
    func configureARSession() {
        UIApplication.shared.isIdleTimerDisabled = true
        sceneView.session.run(configuration, options: .resetTracking)
    }
    
    func setUpTimer() {
        timer.invalidate() // just in case this button is tapped multiple times
        timer = Timer.scheduledTimer(timeInterval: timerAccuracy, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    func setUpMotionManager() {
        if motionManager.isDeviceMotionAvailable == true {
            motionManager.deviceMotionUpdateInterval = 0.2;
            motionManager.startDeviceMotionUpdates(to: OperationQueue(), withHandler: { [self] (motion, error) -> Void in
                if let attitude = motion?.attitude {
                    let pitch = attitude.pitch * 180.0/Double.pi
                    if (pitch > 60) {
                        self.isPitchCorrect = true
                        self.motionManager.stopDeviceMotionUpdates()
                        self.hideView(self.bottomNoticeLabel)
                    }
                }
            })
        }
    }
        
    //MARK:UI set up
    func setUPBottomLabel(){
        sceneView.addSubview(bottomNoticeLabel)
        NSLayoutConstraint.activate([
            bottomNoticeLabel.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            bottomNoticeLabel.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -100)
            ]
        )
        bottomNoticeLabel.setUp(text: "Look Up", size: 20)
        //showView(bottomNoticeLabel)
    }
    
    func setUpStartGameButton(){
        startGameButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStartGameButtonTouched)))
        sceneView.addSubview(startGameButton)
        NSLayoutConstraint.activate([
            startGameButton.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            startGameButton.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -24)
            ]
        )
        startGameButton.setUp(text: "Start Game", size: 30)
        //showView(startGameButton)
    }
    
    func setUpInstructionLabel() {
        sceneView.addSubview(instructionLabel)
        instructionLabel.setConstraint()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.instructionLabel.show(text: "Adjust phone to preferred position and tap Start button", duration: 3)
        }
    }
    
    func setUpScoreLabel() {
        sceneView.addSubview(scoreLabel)
        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.topAnchor, constant: 12)
            ]
        )
        scoreLabel.setUp(text: "0", size: 24)
    }
    
    func setUpReplayButton() {
        replayButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onReplayButtonTouched)))
        sceneView.addSubview(replayButton)
        NSLayoutConstraint.activate([
            replayButton.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            replayButton.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -24)
            ]
        )
        replayButton.setUp(size: 80)
        hideView(replayButton)
    }
    
    func setUpStopButton() {
        stopButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStopButtonTouched)))
        sceneView.addSubview(stopButton)
        NSLayoutConstraint.activate([
            stopButton.centerYAnchor.constraint(equalTo: sceneView.centerYAnchor),
            stopButton.rightAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.rightAnchor, constant: -12)
            ]
        )
        stopButton.setUp(size: 30, padding: 8)
    }
    
    func setUpGoBackButton() {
        goBackButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onGoBackTouched)))
        sceneView.addSubview(goBackButton)
        NSLayoutConstraint.activate([
            goBackButton.rightAnchor.constraint(equalTo: replayButton.leftAnchor, constant: -12),
            goBackButton.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -24)
            ]
        )
        goBackButton.setUp(size: 60)
        hideView(goBackButton)
    }
}

//MARK: renderer()
extension MainGameViewController:ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if !isPlayerDead {
            guard let pointOfView = sceneView.pointOfView else { return }
            
            updatePositionAndOrientationOf(player, withPosition: SCNVector3(0, 0, -playerInitialDistance), relativeTo: pointOfView)
                //check if player is inbound
                let x = player.position.x
                let y = player.position.y
                let z = player.position.z
                let maxXOffset = GameFlowController.shared.maxPlayerXOffset
                let maxYOffset = GameFlowController.shared.maxPlayerYOffset
                if x < -maxXOffset {
                    player.position.x = -maxXOffset
                }
                if x > maxXOffset {
                    player.position.x = maxXOffset
                }
                if y < -maxYOffset {
                    player.position.y = -maxYOffset
                }
                if y > maxYOffset {
                    player.position.y = maxYOffset
                }
                if z < -(playerInitialDistance + playerMaxDistanceOffset) {
                    player.position.z = -(playerInitialDistance + playerMaxDistanceOffset)
                }
                if z > playerInitialDistance + playerMaxDistanceOffset {
                    player.position.z = playerInitialDistance + playerMaxDistanceOffset
                }
                
                //disable some degree of freedom
                player.eulerAngles.x = 0
                player.eulerAngles.y = 0
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor{
            let planeNode = setUpSurroundingDetection(anchor: anchor)
            node.addChildNode(planeNode)
        }
        
    }
        
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor{
            node.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
            }
            let planeNode = setUpSurroundingDetection(anchor: anchor)
            node.addChildNode(planeNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor{
            node.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
            }
        }
    }
    
    func setUpSurroundingDetection(anchor: ARPlaneAnchor) -> SCNNode{
        var planeNode = SCNNode()
        //transform setting
        planeNode = SCNNode(geometry: SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z)))
        planeNode.eulerAngles = SCNVector3(Float.pi/2, 0, 0)
        planeNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        //physics collision
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: planeNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        planeNode.physicsBody?.categoryBitMask = Category.plane.rawValue
        planeNode.physicsBody?.isAffectedByGravity = false
        planeNode.physicsBody?.contactTestBitMask = Category.player.rawValue
        planeNode.physicsBody?.collisionBitMask = Category.player.rawValue
        //occlusion
        let maskMaterial = SCNMaterial()
        maskMaterial.diffuse.contents = UIColor.white
        maskMaterial.colorBufferWriteMask = []
        
        // occlude (render) from both sides please
        maskMaterial.isDoubleSided = true
        //assign material
        planeNode.geometry?.firstMaterial? = maskMaterial
        planeNode.categoryBitMask = 0
        return planeNode
    }
}

//MARK: Physics
extension MainGameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if isPlayerDead { return }
        if contact.nodeA.name == "player" || contact.nodeB.name == "player" {
            if contact.nodeB.name == "obstacle" || contact.nodeA.name == "obstacle" {
                handlePlayerDeath()
            }
            if contact.nodeB.name == "pass" {
                handlePlayerPass(node: contact.nodeB)
            }
            if contact.nodeA.name == "pass" {
                handlePlayerPass(node: contact.nodeA)
            }
        }
    }
}

//MARK: Game Flow Control
extension MainGameViewController {
    @objc func timerAction() {
        timePassed += timerAccuracy
        if timePassed > GameFlowController.shared.instanciateInterval {
            timePassed = 0.0
            addObstacle()
        }
        scoreLabel.label.text = String(Int(GameFlowController.shared.timeSinceStart))
    }
    
    private func addObstacle() {
        sceneView.scene.rootNode.addChildNode(GameNodes.getObstacle())
    }
    
    func handlePlayerPass(node: SCNNode) {
        node.parent?.childNode(withName: "obstacle", recursively: false)?.runAction(SCNAction.sequence([SCNAction.fadeOut(duration: 0.3), SCNAction.customAction(duration: 0, action: { (node, _) in
            node.removeEverything()
        })]))
        node.parent?.runAction(SCNAction.sequence([SCNAction.wait(duration: 0.3), SCNAction.customAction(duration: 0, action: { (node, _) in
            node.removeEverything()
        })]))
    }
    
    private func handlePlayerDeath() {
        AudioServicesPlaySystemSound(1519)
        player.physicsBody?.isAffectedByGravity = true
        timer.invalidate()
        isPlayerDead = true
        //score
        let score = Int(GameFlowController.shared.timeSinceStart.rounded())
        GameController.shared.lastScore = score
        //new high score
        if score > GameController.shared.highScore {
            GameController.shared.highScore = score
            sendScoreToGameCenter(score: score)
        }
        if score > 30 {
            GameController.shared.isFirstTimePlay = false
        }
        //give metals
        let metalsEarned = Int(score / 10)
        if metalsEarned > 0 {
            GameController.shared.metals += metalsEarned
            instructionLabel.show(text: "You got \(metalsEarned) metals", duration: 2)
        }
        
        //clear obstacles
        sceneView.scene.rootNode.childNodes.forEach { (node) in
            if node.name == "obstacle" {
                node.removeEverything()
            }
        }
        //UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showView(self.goBackButton)
            self.showView(self.replayButton)
        }
        //reset
        GameFlowController.shared.reset()
//        print("DEAD")
    }
    
    
}

//MARK: UI
extension MainGameViewController {
    /**
        Show a stretchable notice label on the bottom of the screen
        - Duration: Stay for 3 seconds and fade in 1 seconds
        - Parameter notice: notice to give to users
     */
    private func showViewAndFade(_ label: UIView){
            DispatchQueue.main.async {
                label.isHidden = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                UIView.animate(withDuration: 1, animations: {
                    label.isHidden = true
                })
            }
    }
    
    private func showView(_ label: UIView) {
        DispatchQueue.main.async {
            label.isHidden = false
        }
    }
    
    private func hideView(_ label: UIView) {
        DispatchQueue.main.async {
            label.isHidden = true
        }
    }
    
    @objc private func onStartGameButtonTouched() {
        //reset tracking
        configureARSession()
        shouldStartGame = true
        timePassed = 0.0
        isPlayerDead = false
        setUpTimer()
        GameFlowController.shared.setUpTimer()
        hideView(startGameButton)
        //new player tutorial
        if GameController.shared.isFirstTimePlay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.instructionLabel.show(text: "Avoid the obstacles by moving and rotating your phone", duration: 10)
                DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
                    self.instructionLabel.show(text: "You can move forward or backward to avoid the hammers", duration: 8)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        self.instructionLabel.show(text: "Pause game with button on the right to have a rest", duration: 8)
                    }
                }
            })
        }
    }
    
    @objc private func onStopButtonTouched() {
        if (GameFlowController.shared.isPaused) {
            instructionLabel.show(text: "Game resumed", duration: 3)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                UIApplication.shared.isIdleTimerDisabled = true
                GameFlowController.shared.isPaused = false
                self?.configureARSession()
                self?.sceneView.scene.isPaused = false
                self?.setUpTimer()
            }
        } else {
            UIApplication.shared.isIdleTimerDisabled = false
            GameFlowController.shared.isPaused = true
            sceneView.session.pause()
            sceneView.scene.isPaused = true
            timer.invalidate()
            instructionLabel.show(text: "Game paused. You can have a rest and adjust to a more comfortable position", duration: 6)
        }
    }
    
    @objc private func onReplayButtonTouched() {
        player.removeEverything()
        player = GameNodes.getPlayer()
        sceneView.scene.rootNode.addChildNode(player)
        onStartGameButtonTouched()
        hideView(goBackButton)
        hideView(replayButton)
    }
    
    @objc private func onGoBackTouched() {
        onDoneBlock?()
        dismiss(animated: false)
    }
}
