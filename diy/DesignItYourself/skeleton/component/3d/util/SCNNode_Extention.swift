//
//  SCNNode_Extention.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 8/26/24.
//

import Foundation
import SwiftUI
import SceneKit

extension Float {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

extension SCNNode{
    enum Axis {
        case x, y, z
        var normal: SIMD3<Float> {
            switch self {
            case .x: return SIMD3(1, 0, 0)
            case .y: return SIMD3(0, 1, 0)
            case .z: return SIMD3(0, 0, 1)
            }
        }
    }
    @discardableResult
    func setName(_ name:String) -> SCNNode {
        self.name = name
        self.childNodes.forEach{$0.setName(name)}
        return self
    }
    
    @discardableResult
    func updateSkin(named:String? = nil, scale:Float = 1)->SCNNode {
        guard let named = named else {return self}
        guard let material = self.geometry?.materials.first else {return self}
        let scnScale = SCNMatrix4MakeScale(scale, scale, 0.0)
        let translateAndScale = SCNMatrix4Translate(scnScale, 0, 0.0, 0.0)
        material.diffuse.contents = UIImage(named:named)
        material.diffuse.contentsTransform = translateAndScale
        material.diffuse.wrapS = .repeat
        material.diffuse.wrapT = .repeat
        let history = "USk," + named + "," + scale.description
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func updateColor(color:Color)->SCNNode {
        guard let material = self.geometry?.materials.first else {return self}
        material.diffuse.contents = UIColor(color)
        let history = "UClo," + color.toHexString()
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func setX(_ amount:Float = 0) -> SCNNode {
        self.simdWorldPosition.x = simd_float1(amount)/2
        let history = "SX," + amount.description
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func setY(_ amount:Float = 0) -> SCNNode {
        self.simdWorldPosition.y = simd_float1(amount)/2
        let history = "SY," + amount.description
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func setZ(_ amount:Float = 0) -> SCNNode {
        self.simdWorldPosition.z = simd_float1(amount)/2
        let history = "SZ," + amount.description
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func moveX(_ amount:Float = 1) -> SCNNode {
        self.simdWorldPosition += simd_float1(amount*SceneFactory.planckLength) * Axis.x.normal
        let history = "MX," + amount.description
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func moveY(_ amount:Float = 1) -> SCNNode {
        self.simdWorldPosition += simd_float1(amount*SceneFactory.planckLength) * Axis.y.normal
        let history = "MY," + amount.description
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func moveZ(_ amount:Float = 1) -> SCNNode {
        self.simdWorldPosition += simd_float1(amount*SceneFactory.planckLength) * Axis.z.normal
        let history = "MZ," + amount.description
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func normalX() -> SCNNode {
        self.simdWorldOrientation = simd_quatf.init(angle: .pi/2, axis: Axis.z.normal)
        let history = "NX"
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func normalY() -> SCNNode {
        self.simdWorldOrientation = simd_quatf.init(angle: .pi/2, axis: Axis.y.normal)
        let history = "NY"
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func normalZ() -> SCNNode {
        self.simdWorldOrientation = simd_quatf.init(angle: .pi/2, axis: Axis.x.normal)
        let history = "NZ"
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func setOrientationX(_ degrees:Float = 0, dr:Float = 1) -> SCNNode {
        self.simdWorldOrientation = simd_quatf.init(angle: degrees.degreesToRadians , axis: Axis.z.normal)
        let history = "SOX," + degrees.description + "," + dr.description
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func setOrientationY(_ degrees:Float = 0, dr:Float = 1) -> SCNNode {
        self.simdWorldOrientation = simd_quatf.init(angle: degrees.degreesToRadians , axis: Axis.y.normal)
        
        let history = "SOY," + degrees.description + "," + dr.description
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func setOrientationZ(_ degrees:Float = 0, dr:Float = 1) -> SCNNode {
        self.simdWorldOrientation = simd_quatf.init(angle: degrees.degreesToRadians , axis: Axis.x.normal)
        
        let history = "SOZ," + degrees.description + "," + dr.description
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func moveRotation(_ degrees:Float = 15, x:Float = 0, y:Float = 0, z:Float = 0) -> SCNNode {
        let newTransform = SCNMatrix4Rotate(self.transform, degrees.degreesToRadians , x, y, z)
        self.transform = newTransform
        
        let history = "MR," + degrees.description
        + "," + x.description
        + "," + y.description
        + "," + z.description
        + "," + Date().timeIntervalSince1970.description
        self.updateHistory(history)
        return self
    }
    
    @discardableResult
    func replay(_ value:String) -> String? {
        let div = value.components(separatedBy: ",")
        guard let cmd = div.first else {return nil}
        switch cmd {
        case "USk" :
            self.updateSkin(named: div[safe: 1], scale: div[safe: 2]?.toFloat() ?? 1)
            return div[safe: 3]
        case "UClo" :
            let color = Color(hexaDecimalString: div[safe: 1] ?? "")
            self.updateColor(color: color)
            return div[safe: 2]
        case "SX" :
            self.setX(div[safe: 1]?.toFloat() ?? 0)
            return div[safe: 2]
        case "SY" :
            self.setY(div[safe: 1]?.toFloat() ?? 0)
            return div[safe: 2]
        case "SZ" :
            self.setZ(div[safe: 1]?.toFloat() ?? 0)
            return div[safe: 2]
            
        case "MX" :
            self.moveX(div[safe: 1]?.toFloat() ?? 0)
            return div[safe: 2]
        case "MY" :
            self.moveY(div[safe: 1]?.toFloat() ?? 0)
            return div[safe: 2]
        case "MZ" :
            self.moveZ(div[safe: 1]?.toFloat() ?? 0)
            return div[safe: 2]
            
        case "NX" :
            self.normalX()
            return div[safe: 1]
        case "NY" :
            self.normalY()
            return div[safe: 1]
        case "NZ" :
            self.normalZ()
            return div[safe: 1]
            
        case "SOX" :
            self.setOrientationX(
                div[safe: 1]?.toFloat() ?? 0,
                dr: div[safe: 2]?.toFloat() ?? 1
            )
            return div[safe: 3]
        case "SOY" :
            self.setOrientationY(
                div[safe: 1]?.toFloat() ?? 0,
                dr: div[safe: 2]?.toFloat() ?? 1
            )
            return div[safe: 3]
        case "SOZ" :
            self.setOrientationZ(
                div[safe: 1]?.toFloat() ?? 0,
                dr: div[safe: 2]?.toFloat() ?? 1
            )
            return div[safe: 3]
        case "MR" :
            self.moveRotation(
                div[safe: 1]?.toFloat() ?? 15,
                x: div[safe: 2]?.toFloat() ?? 0,
                y: div[safe: 3]?.toFloat() ?? 0,
                z: div[safe: 4]?.toFloat() ?? 0
            )
            return div[safe: 5]
        default : return nil
        }
    }
    
    private func updateHistory(_ value:String){
        SceneWorldModel.shared?.addHistory(name: self.name, value: value)
    }
    /*
    @discardableResult
    func setScale(x:Float = 1.0, y:Float = 1.0, z:Float = 1.0) -> SCNNode {
        self.simdWorldTransform = simd_float4x4(
            SIMD4(x, 0, 0, 0),
            SIMD4(0, y, 0, 0),
            SIMD4(0, 0, z, 0),
            SIMD4(0, 0, 0, 0)
        )
        return self
    }
    @discardableResult
    func moveScale(x:Float = 0.0, y:Float = 0.0, z:Float = 0.0) -> SCNNode {
        let sc = self.scale
        self.scale = SCNVector3(sc.x+x, sc.y+y, sc.z+z)
        return self
    }
     @discardableResult
     func addBloom(_ amount:Float = 5) -> SCNNode {
         let bloomFilter = CIFilter(name:"CIBloom")!
         bloomFilter.setValue(amount, forKey: "inputIntensity")
         bloomFilter.setValue(amount, forKey: "inputRadius")
         self.filters = [bloomFilter]
         return self
     }
    */
}
