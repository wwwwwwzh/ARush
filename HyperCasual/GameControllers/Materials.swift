//
//  Materials.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/14.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import Foundation
import SceneKit

class Materials {
    static func getMaterial() -> SCNMaterial {
        print(GameController.shared.gameTheme)
        switch GameController.shared.gameTheme {
        case .metallic:
            return getMetal()
        case .gold:
            return getMetal(color: UIColor(red: 1, green: 0.84, blue: 0, alpha: 1).cgColor)
        case .amber:
            return getMetal(color: UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor)
        case .future:
            return getMetal(color: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))
        }
    }
}

//MARK: different materials
extension Materials {
    private static func getMetal(color: CGColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 1.0
        material.roughness.contents = 0
        material.isDoubleSided = true
        material.diffuse.contents = color
        material.fillMode = .fill
        return material
    }
}
