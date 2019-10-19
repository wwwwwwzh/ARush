//
//  MetalsCountView.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/18.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import Foundation
import UIKit

class MetalsCountView: UIView {
    
    var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        label.numberOfLines = 1
        label.textColor = UIColor.black
        label.font = UIFont(name: "American Typewriter", size: 18)
        label.backgroundColor = UIColor.clear
        label.text = String(GameController.shared.metals)
        return label
    }()
    
    var imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "gold"))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: topButtonWidth),
            imageView.widthAnchor.constraint(equalToConstant: topButtonWidth),
            ]
        )        
        
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 6),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            label.heightAnchor.constraint(equalToConstant: topButtonWidth),
            label.widthAnchor.constraint(equalToConstant: topButtonWidth),
            ]
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

