//
//  CoordinateGrid.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 8/22/24.
//

import Foundation
import SwiftUI
import SceneKit

class CoordinateGrid: SCNNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(length: Float = 40, radius: Float = 0.1,
         color: (x: Color, y: Color, z: Color, origin: Color) = (
            SceneWorldModel.NodeAxis.X.color ,
            SceneWorldModel.NodeAxis.Y.color ,
            SceneWorldModel.NodeAxis.Z.color,
            Color.app.gray
         ),
         addPlane: Bool = true)
    {
        guard let factory =  SceneFactory.shared else {
            super.init()
            return
        }
        let pl = factory.planckLength * length
        /// x-axis
        let xAxisNode = factory.getCylinder(r:radius, h: length, color: color.x)
            .normalX().setX(pl)
        let xAxisMirrorNode = factory.getCylinder(r:radius, h:length, color:color.x.opacity(0.4))
            .normalX().setX(-pl)
        /// y-axis
        let yAxisNode = factory.getCylinder(r:radius, h: length, color: color.y)
            .normalY().setY(pl)
       
         let yAxisMirrorNode = factory.getCylinder(r:radius, h: length, color: color.y.opacity(0.4))
            .normalY().setY(-pl)
        /// z-axis
        let zAxisNode = factory.getCylinder(r:radius, h: length, color: color.z)
            .normalZ().setZ(pl)
        let zAxisMirrorNode = factory.getCylinder(r:radius, h: length, color: color.z.opacity(0.4))
            .normalZ().setZ(-pl)
        /// dot at origin
        let originNode = factory.getSphere(r:radius*2, color: color.origin)
        
        super.init()
        self.addChildNode(originNode)
        self.addChildNode(xAxisNode)
        self.addChildNode(yAxisNode)
        self.addChildNode(zAxisNode)
        self.addChildNode(xAxisMirrorNode)
        self.addChildNode(yAxisMirrorNode)
        self.addChildNode(zAxisMirrorNode)
        
        if addPlane {
            let plane = factory.getPlane(w: length * 2, h: length * 2, lightingModel: .blinn)
                .updateSkin(named: "grid", scale: length)
          
            plane.simdWorldOrientation = simd_quatf.init(angle: -.pi/2, axis: Axis.x.normal)
            self.addChildNode(plane)
        }
    }
    

}
