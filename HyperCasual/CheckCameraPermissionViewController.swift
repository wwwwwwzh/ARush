//
//  CheckCameraPermissionViewController.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/11/15.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import UIKit
import AVKit

class CheckCameraPermissionViewController: UIViewController {
    
    var splash: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Splash"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkCameraPermission()
    }
    
    func setUpView() {
        view.backgroundColor = UIColor.black
        view.addSubview(splash)
        NSLayoutConstraint.activate([
            splash.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splash.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splash.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            splash.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func checkCameraPermission() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            goToGame()
            GameController.shared.timesOfPlay += 1
        } else {
            DispatchQueue.main.async {
                self.setUpView()
                let alertController = UIAlertController(title: localizedString("Grant camera permission"), message: localizedString("Augmented reality relies on camera to fuse virtual objects with your surroundings"), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: localizedString("No"), style: .destructive) { (_) in
                    self.showAlert(title: localizedString("You must grant camera permission to use the app"), message: localizedString("The game couldn't run without camera access"), buttonTitle: localizedString("Grant Permission"), showCancel: false) { (_) in
                        self.checkCameraPermissionHelper()
                    }
                })
                alertController.addAction(UIAlertAction(title: localizedString("Yes"), style: .default) { (_) in
                    self.checkCameraPermissionHelper()
                })
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func checkCameraPermissionHelper() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
            if granted {
                self.showAlert(title: localizedString("Now point your camera to objects around you"), message: "", buttonTitle: localizedString("OK"), showCancel: false) { (_) in
                    self.goToGame()
                }
            } else {
                self.showAlert(title: localizedString("Please go to settings to grant permission"), message: localizedString("The game couldn't run without camera access"), buttonTitle: localizedString("Settings"), showCancel: true) { (_) in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        })
    }
    
    func goToGame() {
        DispatchQueue.main.async {
            if GameController.shared.isFirstTimePlay {
                let vc = MainGameViewController()
                vc.modalPresentationStyle = .fullScreen
                self.show(vc, sender: nil)
            } else {
                let vc = MenuViewController()
                vc.modalPresentationStyle = .fullScreen
                self.show(vc, sender: nil)
            }
        }
    }
}
