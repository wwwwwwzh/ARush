//
//  NoticePaddingLabel.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/14.
//  Copyright © 2019 Yu Wang. All rights reserved.
//
import UIKit

class NoticePaddingLabel: UILabel {
    var topInset:CGFloat = 8
    var bottomInset:CGFloat = 8
    var leftInset:CGFloat = 8
    var rightInset:CGFloat = 8
    var maxWidth = CGFloat(240)
    
    var blurView: UIVisualEffectView!
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    /**
     use this for instruction overlay
     */
    convenience init(clearBackground: Bool, maxWidth: CGFloat = 240, color: UIColor = UIColor.black) {
        self.init()
        setUp()
        if clearBackground {
            backgroundColor = UIColor.clear
        }
        preferredMaxLayoutWidth = maxWidth
        textColor = color
    }
    
    private func setUp(){
        sizeToFit()
        numberOfLines = 0
        textColor = UIColor.black
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.8)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8
        layer.masksToBounds = true
        preferredMaxLayoutWidth = maxWidth
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width+leftInset+rightInset, height: size.height+topInset+bottomInset)
    }
    
    func setInsets(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat){
        topInset = top
        bottomInset = bottom
        leftInset = left
        rightInset = right
    }
}
