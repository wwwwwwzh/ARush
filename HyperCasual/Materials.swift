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
        switch GameController.shared.gameTheme {
        case .metallic:
            return getMetal()
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
