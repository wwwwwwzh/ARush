//
//  BluredView.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/16.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import UIKit

class BluredView: UIView {
    
    var cornerRadius = CGFloat(8)

    var label = NoticePaddingLabel(clearBackground: true)
    
    var shimmerLabel = NoticePaddingLabel(clearBackground: true)
    
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light))
    
    var icon: UIImageView?
    
    var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.5, 1]
        gradient.frame = CGRect(x: 0, y: 0, width: 200, height: 80)
        
        let angle = CGFloat.pi * 45 / 180
        gradient.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        return gradient
    }()
    
    static var animation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 1.5
        animation.fromValue = -100
        animation.toValue = 100
        animation.repeatCount = Float.infinity
        return animation
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        backgroundColor = UIColor.clear
        
        blurView.frame = self.bounds
        blurView.layer.cornerRadius = cornerRadius
        blurView.layer.masksToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(blurView)
    }
    
    convenience init(cornerRadius: CGFloat) {
        self.init()
        layer.cornerRadius = cornerRadius
        self.cornerRadius = cornerRadius
    }
    
    /**
     An icon blur button
     */
    convenience init(icon: UIImage) {
        self.init(cornerRadius: 4)
        label.text = nil
        self.icon = UIImageView(image: icon)
        self.icon?.contentMode = .scaleAspectFit
        self.icon?.backgroundColor = UIColor.clear
        self.icon?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /**
     Used for buttons
     Call this after the view's constraint has been set
     */
    func setUp(size: CGFloat, padding: CGFloat = 12) {
        if let icon = icon {
            addSubview(icon)
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: size),
                heightAnchor.constraint(equalToConstant: size),
                ]
            )
            NSLayoutConstraint.activate([
                icon.centerYAnchor.constraint(equalTo: centerYAnchor),
                icon.centerXAnchor.constraint(equalTo: centerXAnchor),
                icon.widthAnchor.constraint(equalTo: widthAnchor, constant: -padding * 2),
                icon.heightAnchor.constraint(equalTo: heightAnchor, constant: -padding * 2),
                ]
            )
        } else {
            setUp(text: "X")
        }
    }
    
    /**
     Used for labels
     Call this after the view's constraint has been set
     */
    func setUp(text: String, size: Int = 18, adjustToSystem: Bool = true, shimmer: Bool = false) {
        addSubview(label)
        DispatchQueue.main.async { [weak self] in
            self?.label.text = text
            self?.label.font = UIFont.getCustomeSystemAdjustedFont(withSize: size, adjustSizeAccordingToSystem: adjustToSystem)
        }
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            ]
        )
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: label.widthAnchor, constant: cornerRadius + 24),
            heightAnchor.constraint(equalTo: label.heightAnchor),
            ]
        )
        
        //add shimmer and animation
        if shimmer {
            addSubview(shimmerLabel)
            shimmerLabel.textColor = UIColor.white
            DispatchQueue.main.async { [weak self] in
                self?.shimmerLabel.text = self?.label.text
                self?.shimmerLabel.font = self?.label.font
            }
            NSLayoutConstraint.activate([
                shimmerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                shimmerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                ]
            )
            DispatchQueue.main.async { [weak self] in
                self?.gradient.add(BluredView.animation, forKey: "shimmer")
                self?.shimmerLabel.layer.mask = self?.gradient
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    

}
