//
//  CustomSwitch.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/26.
//

import Foundation
import SwiftUI
import SceneKit
import UIKit



class SceneFactory {
    private(set) static var shared: SceneFactory? = nil
    let planckLength:Float
    static var planckLength:Float {
        return Self.shared?.planckLength ?? 0.5
    }
    init(planckLength: Float = 0.5) {
        self.planckLength = planckLength
        Self.shared = self
    }
    
    func getPlane(w:Float = 10, h:Float = 10,
                  color:Color = Color.app.blue, 
                  lightingModel:SCNMaterial.LightingModel = .physicallyBased) ->SCNNode {
        let p = self.planckLength
        let plane = SCNPlane(width: CGFloat(w * p), height: CGFloat(h * p))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(color)
        material.lightingModel = lightingModel
        material.isDoubleSided = true
        plane.materials = [material]
        return SCNNode(geometry: plane)
    }
    func getBox(x:Float = 1, y:Float = 1, z:Float = 1, 
                color:Color = Color.app.blue,
                lightingModel:SCNMaterial.LightingModel = .physicallyBased) ->SCNNode {
        let p = self.planckLength
        let box = SCNBox(
            width: CGFloat(x*p*2),
            height: CGFloat(y*p*2),
            length: CGFloat(z*p*2),
            chamferRadius: 0
        )
            
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(color)
        material.lightingModel = lightingModel
        box.materials = [material]
        return SCNNode(geometry: box)     }
    
    func getSphere(r:Float = 1, 
                   color:Color = Color.app.blue,
                   lightingModel:SCNMaterial.LightingModel = .physicallyBased) ->SCNNode {
        let sphere = SCNSphere(radius: CGFloat(r*self.planckLength))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(color)
        material.lightingModel = lightingModel
        sphere.materials = [material]
        return SCNNode(geometry: sphere)
    }
    
    func getCylinder(r:Float = 1, h:Float = 1, 
                     color:Color = Color.app.blue,
                     lightingModel:SCNMaterial.LightingModel = .physicallyBased) ->SCNNode {
        let cylinder = SCNCylinder(radius: CGFloat(r*self.planckLength), height: CGFloat(h*self.planckLength))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(color)
        material.lightingModel = lightingModel
        cylinder.materials = [material]
        return SCNNode(geometry: cylinder)
    }
   
    func getCone(r:Float = 1, br:Float? = 2, h:Float = 1, 
                 color:Color = Color.app.blue,
                 lightingModel:SCNMaterial.LightingModel = .physicallyBased) ->SCNNode {
        let p = self.planckLength
        let cone = SCNCone(
            topRadius: CGFloat(p*r),
            bottomRadius: CGFloat(p*(br ?? r)),
            height: CGFloat(p*h))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(color)
        material.lightingModel = lightingModel
        cone.materials = [material]
        return SCNNode(geometry: cone)
    }
    
    func getTorus(r:Float = 1, h:Float = 0.2,
                  color:Color = Color.app.blue,
                  lightingModel:SCNMaterial.LightingModel = .physicallyBased) ->SCNNode {
        let p = self.planckLength
        let torus = SCNTorus(ringRadius: CGFloat(p*r), pipeRadius: CGFloat(p*r*h))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(color)
        material.lightingModel = lightingModel
        material.fillMode = .fill
        torus.materials = [material]
        return SCNNode(geometry: torus)
    }

    /*
     struct Vertex {
         let x: Float
         let y: Float
         let z: Float
     }
    private func getCubeVertices() -> [Vertex]{
        let p = self.planckLength
        return [
            Vertex(x: -p, y: -p, z: -p),
            Vertex(x: p, y: -p, z: -p),
            Vertex(x: p, y: p, z: -p),
            Vertex(x: -p, y: p, z: -p),
            Vertex(x: -p, y: -p, z: p),
            Vertex(x: p, y: -p, z: p),
            Vertex(x: p, y: p, z: p),
            Vertex(x: -p, y: p, z: p)
        ]
    }
    func getCube(x:Float = 1, y:Float = 1, z:Float = 1, color:Color = Color.app.blue) ->SCNNode {
        let vertices = self.getCubeVertices()
        let verticesConverted = vertices.map { SCNVector3($0.x*x, $0.y*y, $0.z*z) }
        let positionSource = SCNGeometrySource(vertices: verticesConverted)
        let indices: [UInt16] = [
            2, 1, 3, 3, 1, 0, // Front face.
            0, 1, 4, 4, 1, 5, // Bottom face.
            1, 2, 5, 5, 2, 6, // Right face.
            2, 3, 6, 6, 3, 7, // Top face.
            3, 0, 4, 4, 7, 3, // Left face.
            4, 5, 7, 7, 5, 6 // Rear face.
        ]
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [positionSource], elements: [element])
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(color)
        material.lightingModel = .physicallyBased
        geometry.materials = [material]
        return SCNNode(geometry: geometry)
    }
    */
}


