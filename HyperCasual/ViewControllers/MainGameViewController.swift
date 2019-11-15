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
    
    var passedObstacle: SCNNode?
    
    var wall: SCNNode?
    
    var isPlayerDead = false
        
    var timer = Timer()
    
    var timePassed = 0.0
    
    //UI
    var instructionLabel = InstructionOverlayView()
    
    var tutorialOverlay = TutorialOverlay()
    
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
        
        //sceneView.debugOptions = [.showPhysicsShapes]
        
        setUpInstructionLabel()
        setUpTutorialOverlay()
        setUpScoreLabel()
        
        if !GameController.shared.isFirstTimePlay {
            setUpReplayButton()
            setUpStopButton()
            setUpGoBackButton()
        }
        
        player = GameNodes.getPlayer()
        sceneView.scene.rootNode.addChildNode(player)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureARSession()
        //CABasicAnimation must start in ViewWillAppear
        if !GameController.shared.isFirstTimePlay {
            setUpStartGameButton()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
         if GameController.shared.isFirstTimePlay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.onStartGameButtonTouched()
            }
        }
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
            return
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
        sceneView.session.run(configuration, options: [])
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let transform = self.sceneView.pointOfView?.simdTransform {
                self.sceneView.session.setWorldOrigin(relativeTransform: transform)
            }
        }
    }
    
    func setUpTimer() {
        timer.invalidate() // just in case this button is tapped multiple times
        timer = Timer.scheduledTimer(timeInterval: timerAccuracy, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    //MARK:UI set up
    func setUpStartGameButton(){
        startGameButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onStartGameButtonTouched)))
        sceneView.addSubview(startGameButton)
        NSLayoutConstraint.activate([
            startGameButton.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            startGameButton.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -24)
            ]
        )
        startGameButton.setUp(text: localizedString("Start Game"), size: 30, adjustToSystem: false, shimmer: true)
    }
    
    func setUpInstructionLabel() {
        sceneView.addSubview(instructionLabel)
        instructionLabel.setConstraint()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !GameController.shared.isFirstTimePlay {
                self.instructionLabel.show(text: localizedString("Adjust to a comfortable position and hit start"), duration: 3)
            } else {
                self.instructionLabel.show(text: localizedString("Avoid incoming objects by moving and rotating your device in all dimensions"), duration: 5)
            }
        }
    }
    
    func setUpTutorialOverlay() {
        sceneView.addSubview(tutorialOverlay)
        tutorialOverlay.setConstraint()
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
        hideView(stopButton)
    }
    
    func setUpGoBackButton() {
        goBackButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onGoBackTouched)))
        sceneView.addSubview(goBackButton)
        NSLayoutConstraint.activate([
            goBackButton.leftAnchor.constraint(equalTo: sceneView.leftAnchor, constant: 12),
            goBackButton.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -24)
            ]
        )
        goBackButton.setUp(size: 60)
        //hideView(goBackButton)
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
            
            var shouldShowWall = false
            if x < -maxXOffset {
                player.position.x = -maxXOffset
                shouldShowWall = true
            }
            if x > maxXOffset {
                player.position.x = maxXOffset
                shouldShowWall = true
            }
            if y < -maxYOffset {
                player.position.y = -maxYOffset
                shouldShowWall = true
            }
            if y > maxYOffset {
                player.position.y = maxYOffset
                shouldShowWall = true
            }
            if z < -(playerInitialDistance + playerMaxDistanceOffset) {
                player.position.z = -(playerInitialDistance + playerMaxDistanceOffset)
            }
            if z > -playerInitialDistance + playerMaxDistanceOffset {
                player.position.z = -playerInitialDistance + playerMaxDistanceOffset
            }
            
            if shouldShowWall {
                showWall()
            } else {
                dismissWall()
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
    
    func showWall() {
        if !GameFlowController.shared.wallExisted {
            wall = GameNodes.getWall()
            wall!.runAction(SCNAction.fadeIn(duration: 0.2))
            wall!.position.z = -0.5
            sceneView.scene.rootNode.addChildNode(wall!)
            GameFlowController.shared.wallExisted = true
        }
    }
    
    func dismissWall() {
        if wall == nil { return }
        let dismissAction = SCNAction.sequence([SCNAction.fadeOut(duration: 1), SCNAction.customAction(duration: 0, action: { (node, _) in
            node.removeEverything()
            GameFlowController.shared.wallExisted = false
        })])
        wall?.runAction(dismissAction)
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
        DispatchQueue.main.async {
            self.scoreLabel.label.text = String(Int(GameFlowController.shared.timeSinceStart))
        }
    }
    
    private func addObstacle() {
        sceneView.scene.rootNode.addChildNode(GameNodes.getObstacle())
        if GameController.shared.isFirstTimePlay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tutorialOverlay.playAnimation()
                var directionString = ""
                switch GameFlowController.shared.currentDirection {
                case .down:
                    directionString = localizedString("up")
                case .up:
                    directionString = localizedString("down")
                case .left:
                    directionString = localizedString("right")
                case .right:
                    directionString = localizedString("left")
                case .wall:
                    directionString = ""
                case .rotate:
                    directionString = "rotate"
                case .end:
                    directionString = ""
                }
                if GameFlowController.shared.currentDirection == .wall {
                    self.instructionLabel.show(text: localizedString("You can't surpass the boundary indicated by the blue tunnel"), duration: 3)
                } else if GameFlowController.shared.currentDirection == .rotate {
                    self.instructionLabel.show(text: localizedString("Rotate your device"), duration: 2)
                } else if GameFlowController.shared.currentDirection == .end {
                    self.instructionLabel.show(text: localizedString("Enjoy your game!"), duration: 3)
                } else {
                    self.instructionLabel.show(text: "\(localizedString("Move your device")) \(directionString)", duration: 2)
                }
            }
        }
    }
    
    func handlePlayerPass(node: SCNNode) {
        if node != passedObstacle {
            //fade and remove obstacle
            node.parent?.childNode(withName: "obstacle", recursively: false)?.runAction(SCNAction.sequence([SCNAction.fadeOut(duration: 0.2), SCNAction.customAction(duration: 0, action: { (node, _) in
                node.removeEverything()
            })]))
            //wait and remove pass
            node.runAction(SCNAction.sequence([SCNAction.wait(duration: 0.2), SCNAction.customAction(duration: 0, action: { (node, _) in
                node.removeEverything()
            })]))
            //wait and remvoe parent
            node.parent?.runAction(SCNAction.sequence([SCNAction.wait(duration: 0.2), SCNAction.customAction(duration: 0, action: { (node, _) in
                node.removeEverything()
            })]))
            passedObstacle = node
            
            MusicPlayer.shared.playSoundEffect()
            
            if GameController.shared.isFirstTimePlay && !isPlayerDead {
                GameFlowController.shared.directions.remove(at: 0)
                if GameFlowController.shared.directions.isEmpty {
                    onGoBackTouched()
                }
            }
        }
    }
    
    private func handlePlayerDeath() {
        if GameController.shared.isHapticOn {
            AudioServicesPlaySystemSound(1519)
        }
        player.physicsBody?.isAffectedByGravity = true
        timer.invalidate()
        isPlayerDead = true
        //score
        let score = Int(GameFlowController.shared.timeSinceStart.rounded())
        switch GameController.shared.gameMode {
        case .casual:
            if score > GameController.shared.highScoreCasualMode {
                GameController.shared.highScoreCasualMode = score
                sendScoreToGameCenter(score: score)
            }
        case .rush:
            if score > GameController.shared.highScoreRushMode {
                GameController.shared.highScoreRushMode = score
                sendScoreToGameCenter(score: score)
            }
        }
        
        if GameController.shared.isFirstTimePlay {
            //clear obstacles
            sceneView.scene.rootNode.childNodes.forEach { (node) in
                if let obstacle = node.childNode(withName: "obstacle", recursively: false) {
                    obstacle.removeEverything()
                    obstacle.parent?.removeEverything()
                    obstacle.parent?.childNode(withName: "pass", recursively: false)?.removeEverything()
                }
            }
            //reset
            GameFlowController.shared.reset()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.onReplayButtonTouched()
            }
        } else {
            //give metals
            let metalsEarned = Int(score / 10)
            if metalsEarned > 0 {
                GameController.shared.metals += metalsEarned
                instructionLabel.show(text: "\(localizedString("You got")) \(metalsEarned) \(localizedString("metals"))", duration: 2)
            }
            
            //clear obstacles
            sceneView.scene.rootNode.childNodes.forEach { (node) in
                if let obstacle = node.childNode(withName: "obstacle", recursively: false) {
                    obstacle.removeEverything()
                    obstacle.parent?.removeEverything()
                    obstacle.parent?.childNode(withName: "pass", recursively: false)?.removeEverything()
                }
            }
            //UI
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showView(self.goBackButton)
                self.showView(self.replayButton)
                self.hideView(self.stopButton)
            }
            //reset
            GameFlowController.shared.reset()
        }
    }
}

//MARK: UI
extension MainGameViewController {
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
    
    @objc private func onStartGameButtonTouched(firstPlay: Bool = true) {
        if let transfrom = sceneView.pointOfView?.simdTransform {
            sceneView.session.setWorldOrigin(relativeTransform: transfrom)
        }
        timePassed = 0.0
        isPlayerDead = false
        setUpTimer()
        GameFlowController.shared.setUpTimer()
        hideView(startGameButton)
        showView(stopButton)
    }
    
    @objc private func onStopButtonTouched() {
        if (GameFlowController.shared.isPaused) {
            instructionLabel.show(text: localizedString("Game will resume in 3 seconds, adjust position now"), duration: 3)
            configureARSession()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                UIApplication.shared.isIdleTimerDisabled = true
                GameFlowController.shared.isPaused = false
                self?.sceneView.scene.isPaused = false
                self?.setUpTimer()
            }
        } else {
            UIApplication.shared.isIdleTimerDisabled = false
            GameFlowController.shared.isPaused = true
            sceneView.session.pause()
            sceneView.scene.isPaused = true
            timer.invalidate()
            instructionLabel.show(text: localizedString("Game paused. You can have a rest and adjust to a more comfortable position"), duration: 6)
        }
    }
    
    @objc private func onReplayButtonTouched() {
        player.removeEverything()
        player = GameNodes.getPlayer()
        sceneView.scene.rootNode.addChildNode(player)
        onStartGameButtonTouched(firstPlay: false)
        hideView(goBackButton)
        hideView(replayButton)
    }
    
    @objc private func onGoBackTouched() {
        player.removeEverything()
        DispatchQueue.main.async {
            if GameController.shared.isFirstTimePlay {
                GameController.shared.isFirstTimePlay = false
                let vc = MenuViewController()
                vc.modalPresentationStyle = .fullScreen
                self.show(vc, sender: nil)
            } else {
                self.onDoneBlock?()
                self.dismiss(animated: false)
            }
        }
    }
}
