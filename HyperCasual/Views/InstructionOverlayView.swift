//
//  InstructionOverlayView.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/14.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import UIKit



class InstructionOverlayView: UIView {
    
    let cornerRadius = CGFloat(12)
    
    var label = NoticePaddingLabel(clearBackground: true)
    
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light))
    
    var isAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        backgroundColor = UIColor.clear
        alpha = 0
        
        blurView.frame = self.bounds
        blurView.layer.cornerRadius = 16
        blurView.layer.masksToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(blurView)
    }
    
    func setConstraint() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview!.topAnchor, constant: 60),
            leftAnchor.constraint(equalTo: superview!.leftAnchor, constant: -cornerRadius-1000),
            ]
        )
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: cornerRadius + 12)
            ]
        )
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: label.widthAnchor, constant: cornerRadius + 24),
            heightAnchor.constraint(equalTo: label.heightAnchor),
            ]
        )
    }
    
    func show(text: String, duration: Int = 5) {
        if isAnimating { return }
        isAnimating = true
        label.text = text
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [self] in
            self.transform = self.transform.translatedBy(x: 1000, y: 0)
            self.alpha = 1
            }, completion: { (isCompleted) in
                UIView.animate(withDuration: 0.5, delay: TimeInterval(duration), usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [self] in
                    self.transform = self.transform.translatedBy(x: -1000, y: 0)
                    self.alpha = 0
                    }, completion: { (isCompleted) in
                        self.isAnimating = false
                })
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
