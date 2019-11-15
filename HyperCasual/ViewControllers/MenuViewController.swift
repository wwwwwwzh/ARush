//
//  MenuViewController.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/14.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import UIKit
import ARKit
import GameKit
import StoreKit

let playerOffset: Float = 0.1
let obstacleOffset: Float = 0.45
let swipeTime = 0.5
let topButtonWidth: CGFloat = 35

class MenuViewController: UIViewController {
    
    var sceneView = ARSCNView()
    
    var playersRoot: SCNNode!
    var obstaclesRoot: SCNNode!
    var scoreNode: SCNNode!
    
    
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
             
    var playerRowOffset: SCNVector3 = {
        var v3 = SCNVector3.zero
        let index = PlayerTextureType.allCases.lastIndex(of: GameController.shared.playerTexture)!
        v3.x -= Float(index) * playerOffset
        return v3
    }()
    
    var playerRowOffsetDestination: SCNVector3 = {
        var v3 = SCNVector3.zero
        let index = PlayerTextureType.allCases.lastIndex(of: GameController.shared.playerTexture)!
        v3.x -= Float(index) * playerOffset
        return v3
    }()
    
    var obstacleRowOffset: SCNVector3 = {
        var v3 = SCNVector3.zero
        let index = GameThemeType.allCases.lastIndex(of: GameController.shared.gameTheme)!
        v3.x -= Float(index) * obstacleOffset
        return v3
    }()
    
    var obstacleRowOffsetDestination: SCNVector3 = {
        var v3 = SCNVector3.zero
        let index = GameThemeType.allCases.lastIndex(of: GameController.shared.gameTheme)!
        v3.x -= Float(index) * obstacleOffset
        return v3
    }()
    
    //UI
    var playGameButton = BluredView(cornerRadius: 3)
    var playRushGameButton = BluredView(cornerRadius: 3)
    var buyButton = BluredView(cornerRadius: 3)
    var instructionLabel = InstructionOverlayView()
    var openLeaderBoardButton: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ranking"))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    var isSettingsOpen = false
    var openSettingsButton: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "settings"))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    var soundButton: UIImageView = {
        let imageView = UIImageView(image: GameController.shared.isSoundOn ? #imageLiteral(resourceName: "music-on") : #imageLiteral(resourceName: "music-off"))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    var hapticButton: UIImageView = {
        let imageView = UIImageView(image: GameController.shared.isHapticOn ? #imageLiteral(resourceName: "haptic-on") : #imageLiteral(resourceName: "haptic-off"))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    var metalsLabel = MetalsCountView()
    var openLikeButton: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "recommended"))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    //MARK:viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setUPSceneView()
        setupCamera()
                
        sceneView.delegate = self
        //sceneView.debugOptions = [.showPhysicsShapes]
        //GameController.shared.playerTexture = .none
        setUpPlayers()
        setUpObstacles()
        setUpScore()
        setUpTopRow()
        
        setUpGestures()
        
        authenticateLocalPlayer()
        
        //UI
        setUpBuyButton()
        setUpOpenLeaderboardButton()
        setUpOpenSettingsButton()
        setUpSettingsButtons()
        setUpMetalsView()
        setUpOpenLikeButton()
        setUpInstructionLabel()
        
        toogleButtons()
        
        //request review
        requestReview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureARSession()
        setUpPlayGameButton()
        setUpPlayRushGameButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}

//MARK: viewDidLoad set up funcs
extension MenuViewController {
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
    
    func configureARSession() {
        UIApplication.shared.isIdleTimerDisabled = true
        let config = ARWorldTrackingConfiguration()
        if #available(iOS 12.0, *) {
            config.environmentTexturing = .automatic
        }
        config.isLightEstimationEnabled = true
        sceneView.session.run(config)
    }
    
    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            return
        }
        
        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
        camera.zNear = 0.05
    }
    
    func setUpPlayers(){
        playersRoot = SCNNode()
        let all = PlayerModels.shared.all
        
        var distance = Float(0)
        all.forEach { (node) in
            node.position.x += distance
            distance += playerOffset
            node.childNode(withName: "Identity", recursively: false)?.scale = SCNVector3(playerBoxWidth, playerBoxWidth, playerBoxWidth)
        }
        playersRoot.addChildNodes(all)
        sceneView.scene.rootNode.addChildNode(playersRoot)
    }
    
    func setUpObstacles(){
        obstaclesRoot = SCNNode()
        let all = GameNodes.getMenuViewObstacle()
        
        var distance = Float(0)
        all.forEach { (node) in
            node.position.x += distance
            distance += obstacleOffset
        }
        obstaclesRoot.addChildNodes(all)
        sceneView.scene.rootNode.addChildNode(obstaclesRoot)
    }
    
    func requestReview() {
        if !GameController.shared.hasRated && GameController.shared.timesOfPlay == TIMES_OF_PLAY_FOR_RATING_REQUEST {
            SKStoreReviewController.requestReview()
            GameController.shared.hasRated = true
        }
    }
    
    //MARK: UI
    func setUpScore(){
        sceneView.scene.rootNode.childNode(withName: "Score Root Node", recursively: false)?.removeEverything()
        scoreNode = GameNodes.getScoreLabels()
        scoreNode.name = "Score Root Node"
        sceneView.scene.rootNode.addChildNode(scoreNode)
    }
    
    func setUpTopRow() {
        
    }
    
    func setUpGestures() {
        let left = UISwipeGestureRecognizer(target: self, action: #selector(changePlayer(_:)))
        left.direction = .left
        sceneView.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(changePlayer(_:)))
        right.direction = .right
        sceneView.addGestureRecognizer(right)
    }
    
    func setUpPlayGameButton(){
        playGameButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPlayGameButtonTouched)))
        sceneView.addSubview(playGameButton)
        NSLayoutConstraint.activate([
            playGameButton.leftAnchor.constraint(equalTo: sceneView.leftAnchor, constant: 12),
            playGameButton.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -36)
            ]
        )
        playGameButton.setUp(text: localizedString("Casual"), size: 30, adjustToSystem: false, shimmer: true)
    }
    
    func setUpPlayRushGameButton() {
        playRushGameButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPlayRushGameButtonTouched)))
        sceneView.addSubview(playRushGameButton)
        NSLayoutConstraint.activate([
            playRushGameButton.rightAnchor.constraint(equalTo: sceneView.rightAnchor, constant: -12),
            playRushGameButton.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -36)
            ]
        )
        playRushGameButton.setUp(text: localizedString("Rush"), size: 30, adjustToSystem: false, shimmer: true)
    }
    
    func setUpBuyButton() {
        buyButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBuyButtonTouched)))
        sceneView.addSubview(buyButton)
        NSLayoutConstraint.activate([
            buyButton.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            buyButton.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -36)
            ]
        )
        buyButton.setUp(text: localizedString("Buy"), size: 30)
        buyButton.isHidden = true
    }
    
    func setUpOpenLeaderboardButton() {
        sceneView.addSubview(openLeaderBoardButton)
        NSLayoutConstraint.activate([
            openLeaderBoardButton.leftAnchor.constraint(equalTo: sceneView.leftAnchor, constant: 12),
            openLeaderBoardButton.topAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.topAnchor, constant: 12),
            openLeaderBoardButton.heightAnchor.constraint(equalToConstant: topButtonWidth),
            openLeaderBoardButton.widthAnchor.constraint(equalToConstant: topButtonWidth),
            ]
        )
        openLeaderBoardButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openLeaderboard)))
    }
    
    
    func setUpMetalsView() {
        sceneView.addSubview(metalsLabel)
        NSLayoutConstraint.activate([
            metalsLabel.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor, constant: 0),
            metalsLabel.topAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.topAnchor, constant: 12),
            metalsLabel.heightAnchor.constraint(equalToConstant: topButtonWidth),
            metalsLabel.widthAnchor.constraint(equalToConstant: 3 * topButtonWidth),
            ]
        )
    }
    
    func setUpOpenLikeButton() {
        sceneView.addSubview(openLikeButton)
        NSLayoutConstraint.activate([
            openLikeButton.rightAnchor.constraint(equalTo: sceneView.rightAnchor, constant: -12),
            openLikeButton.topAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.topAnchor, constant: 12),
            openLikeButton.heightAnchor.constraint(equalToConstant: topButtonWidth),
            openLikeButton.widthAnchor.constraint(equalToConstant: topButtonWidth),
            ]
        )
        openLikeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openLike)))
    }
    
    func setUpOpenSettingsButton() {
        sceneView.addSubview(openSettingsButton)
        NSLayoutConstraint.activate([
            openSettingsButton.rightAnchor.constraint(equalTo: sceneView.rightAnchor, constant: -12),
            openSettingsButton.topAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.topAnchor, constant: 24 + topButtonWidth),
            openSettingsButton.heightAnchor.constraint(equalToConstant: topButtonWidth),
            openSettingsButton.widthAnchor.constraint(equalToConstant: topButtonWidth),
            ]
        )
        openSettingsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toogleSettings)))
    }
    
    func setUpSettingsButtons() {
        sceneView.addSubview(soundButton)
        NSLayoutConstraint.activate([
            soundButton.rightAnchor.constraint(equalTo: sceneView.rightAnchor, constant: -12),
            soundButton.topAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.topAnchor, constant:  12 + 2 * (topButtonWidth + 12)),
            soundButton.heightAnchor.constraint(equalToConstant: topButtonWidth),
            soundButton.widthAnchor.constraint(equalToConstant: topButtonWidth),
            ]
        )
        soundButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toogleSound)))
        hideView(soundButton)
        
        sceneView.addSubview(hapticButton)
        NSLayoutConstraint.activate([
            hapticButton.rightAnchor.constraint(equalTo: sceneView.rightAnchor, constant: -12),
            hapticButton.topAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.topAnchor, constant: 12 + 3 * (topButtonWidth + 12)),
            hapticButton.heightAnchor.constraint(equalToConstant: topButtonWidth),
            hapticButton.widthAnchor.constraint(equalToConstant: topButtonWidth),
            ]
        )
        hapticButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toogleHaptic)))
        hideView(hapticButton)
    }
    
    func setUpInstructionLabel() {
        sceneView.addSubview(instructionLabel)
        instructionLabel.setConstraint()
        if GameController.shared.timesOfPlay < TIMES_OF_PLAY_FOR_RATING_REQUEST {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.instructionLabel.isAnimating = false
                self.instructionLabel.show(text: localizedString("Swipe the cubes to change appearance"), duration: 4)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.instructionLabel.isAnimating = false
                    self.instructionLabel.show(text: localizedString("Swipe on the bigger objects to change theme"), duration: 4)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.instructionLabel.isAnimating = false
                        self.instructionLabel.show(text: localizedString("Hit Casual Or Rush Button At Bottom Of Screen To Play"), duration: 5)
                    }
                }
            }
        }
    }
    
    // MARK: AUTHENTICATE LOCAL PLAYER
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error as Any)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
            }
        }
    }
}

//MARK: renderer()
extension MenuViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else {
            return
        }
        if playerRowOffsetDestination.x > playerRowOffset.x {
            playerRowOffset.x += playerOffset / 10
        }
        if playerRowOffsetDestination.x < playerRowOffset.x {
            playerRowOffset.x -= playerOffset / 10
        }
        let playerPosition = SCNVector3(x: 0, y: 0, z: -playerInitialDistance) + playerRowOffset
        updatePositionAndOrientationOf(playersRoot, withPosition: playerPosition, relativeTo: pointOfView)
        //disable some degree of freedom
        playersRoot.eulerAngles.x = 0
        
        //OBSTACLES
        if obstacleRowOffsetDestination.x > obstacleRowOffset.x {
            obstacleRowOffset.x += obstacleOffset / 10
        }
        if obstacleRowOffsetDestination.x < obstacleRowOffset.x {
            obstacleRowOffset.x -= obstacleOffset / 10
        }
        let obstaclePosition = SCNVector3(x: 0, y: 0, z: -playerInitialDistance-0.6) + obstacleRowOffset
        updatePositionAndOrientationOf(obstaclesRoot, withPosition: obstaclePosition, relativeTo: pointOfView)
        //disable some degree of freedom
        obstaclesRoot.eulerAngles.x = 0
        
        //SCORE
        let scorePosition = SCNVector3(x: -0.05, y: 0.15, z: -0.4)
        updatePositionAndOrientationOf(scoreNode, withPosition: scorePosition, relativeTo: pointOfView)
        //disable some degree of freedom
        scoreNode.eulerAngles.x = 0
    }
}


//MARK: UI
extension MenuViewController {
    @objc func changePlayer(_ gestureRecognizer : UISwipeGestureRecognizer) {
        guard let node = sceneView.hitTest(gestureRecognizer.location(in: sceneView), options: [SCNHitTestOption.firstFoundOnly : true]).first?.node else { return }
        if node.getRoot(in: sceneView) == playersRoot {
            let change: Float = gestureRecognizer.direction == .left ? -playerOffset : playerOffset
            let currentX = playerRowOffsetDestination.x.roundedToTenth()
            if (currentX + change) < -(4 * playerOffset) || (currentX + change) > 0 {
                return
            }
            playerRowOffsetDestination.x += change
            GameController.shared.playerTexture = PlayerTextureType.allCases[-Int((currentX + change).roundedToTenth() / playerOffset)]
            toogleButtons()
        } else if node.getRoot(in: sceneView) == obstaclesRoot {
            let change: Float = gestureRecognizer.direction == .left ? -obstacleOffset : obstacleOffset
            let currentX = obstacleRowOffsetDestination.x.roundedToTenth()
            if (currentX + change) < -(3 * obstacleOffset) || (currentX + change) > 0 {
                return
            }
            obstacleRowOffsetDestination.x += change
            GameController.shared.gameTheme = GameThemeType.allCases[-Int((currentX + change).roundedToTenth() / obstacleOffset)]
        }
    }
    
    func toogleButtons() {
        if GameController.shared.ownedPlayers.contains(GameController.shared.playerTexture) {
            showView(playGameButton)
            showView(playRushGameButton)
            hideView(buyButton)
        } else {
            hideView(playGameButton)
            hideView(playRushGameButton)
            showView(buyButton)
        }
    }
    
    @objc func onPlayGameButtonTouched() {
        GameController.shared.gameMode = .casual
        playGame()
    }
    
    @objc func onPlayRushGameButtonTouched() {
        if GameController.shared.isFirstTimePlay {
            showAlert(title: localizedString("Play one casual game first"), message: localizedString("Please follow the casual game tutorial first to better enjoy the game"))
            return
        }
        GameController.shared.gameMode = .rush
        playGame()
    }
    
    func playGame() {
        pause()
        let viewController = MainGameViewController()
        viewController.modalPresentationStyle = .fullScreen
        viewController.onDoneBlock = { [weak self] in
            self?.setUpScore()
            self?.metalsLabel.label.text = String(GameController.shared.metals)
            self?.resume()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.playGameButton.gradient.add(BluredView.animation, forKey: "shimmer")
                self?.playRushGameButton.gradient.add(BluredView.animation, forKey: "shimmer")
            }
        }
        present(viewController, animated: false, completion: nil)
    }
    
    @objc func onBuyButtonTouched() {
        showAlert(title: localizedString("Buy with 100 gold"), message: localizedString("Are you sure to buy this new player with 100 gold"), buttonTitle: localizedString("Yes"), showCancel: true) { (_) in
            if GameController.shared.metals >= 100 {
                GameController.shared.metals -= 100
                self.metalsLabel.label.text = String(GameController.shared.metals)
                GameController.shared.ownedPlayers.append(GameController.shared.playerTexture)
            } else {
                self.showAlert(title: localizedString("No enough gold"), message: localizedString("Play game to earn more gold!"))
            }
        }
    }
    
    @objc func openLeaderboard() {
        if !gcEnabled { return }
        pause()
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = leaderBoardID
        present(gcVC, animated: true, completion: nil)
    }
    
    @objc func toogleSettings() {
        if isSettingsOpen {
            hideView(soundButton)
            hideView(hapticButton)
        } else {
            showView(soundButton)
            showView(hapticButton)
        }
        isSettingsOpen = !isSettingsOpen
    }
    
    @objc func toogleSound() {
        GameController.shared.isSoundOn = !GameController.shared.isSoundOn
        if GameController.shared.isSoundOn {
            MusicPlayer.shared.startBackgroundMusic()
            soundButton.image = #imageLiteral(resourceName: "music-on")
        } else {
            MusicPlayer.shared.stopBackgroundMusic()
            soundButton.image = #imageLiteral(resourceName: "music-off")
        }
    }
    
    @objc func toogleHaptic() {
        GameController.shared.isHapticOn = !GameController.shared.isHapticOn
        if GameController.shared.isHapticOn {
            hapticButton.image = #imageLiteral(resourceName: "haptic-on")
        } else {
            hapticButton.image = #imageLiteral(resourceName: "haptic-off")
        }
    }
    
    @objc func openLike() {
        if !GameController.shared.hasRated && GameController.shared.highScoreCasualMode > 30{
            SKStoreReviewController.requestReview()
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 3) {
                GameController.shared.hasRated = true
            }
        } else {
            guard let writeReviewURL = URL(string: "https://itunes.apple.com/app/id1483938390?action=write-review")
                else { return }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
    
    func pause() {
        UIApplication.shared.isIdleTimerDisabled = false
        sceneView.session.pause()
        sceneView.scene.isPaused = true
    }
    
    func resume() {
        configureARSession()
        sceneView.scene.isPaused = false
    }
}

//MARK: game center
extension MenuViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
        resume()
    }
    
    
}

//MARK: Utilities
extension MenuViewController {
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
}
