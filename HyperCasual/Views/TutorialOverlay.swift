//
//  TutorialOverlay.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/20.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import UIKit

class TutorialOverlay: UIView {
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            ]
        )
        isHidden = true
    }
    
    func setConstraint() {
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            heightAnchor.constraint(equalTo: superview!.heightAnchor),
            widthAnchor.constraint(equalTo: superview!.widthAnchor),
            ]
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playAnimation() {
        DispatchQueue.main.async {
            var translation: (x: CGFloat, y: CGFloat) = (0, 0)
            let direction = GameFlowController.shared.currentDirection
            var rotation: CGFloat = 0
            var imageName = ""
            switch direction {
            case .down:
                imageName = "up"
                translation = (0, -50)
            case .up:
                imageName = "down"
                translation = (0, 50)
            case .left:
                imageName = "right"
                translation = (50, 0)
            case .right:
                imageName = "left"
                translation = (-50, 0)
            case .rotate:
                rotation = -CGFloat.pi / 4
                imageName = "rotate"
                translation = (0, 0)
            case .end:
                return
            }
            self.isHidden = false
            self.imageView.image = UIImage(named: "phone-\(imageName)")
            UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [self] in
                self.imageView.transform = self.imageView.transform.translatedBy(x: translation.x, y: translation.y)
                self.imageView.transform = self.imageView.transform.rotated(by: rotation)
                }, completion: { (_) in
                    self.imageView.transform = self.imageView.transform.translatedBy(x: -translation.x, y: -translation.y)
                    self.imageView.transform = self.imageView.transform.rotated(by: -rotation)
                    self.isHidden = true
            })
        }
    }
    
}
