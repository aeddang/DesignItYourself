//
//  MaterialData.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 9/24/24.
//

import Foundation
import SwiftUI

extension MaterialData {
    static func getFoundationDescription(_ v:Int?, max:Int)->String{
        let v = v ?? max
        let m = floor(Double(v)/1000)
        let cm = floor(Double(v%1000)/10)
        let mm = Double(v%10)
        var value = ""
        if m > 0 {
            value = m.toInt().description + "m"
        }
        value += cm.toInt().description + "cm"
        
        if mm > 0 {
            value += mm.toInt().description + "mm"
        }
        return value
    }
}
class MaterialData:InfinityData, ObservableObject {
    
    private(set) var type:SceneWorldModel.NodeType
    private(set) var title:String? = nil
    private(set) var text:String? = nil
    private(set) var price:String? = nil
    private(set) var unit:Int = 10
    private(set) var foundationX:Range<Int>? = nil
    private(set) var foundationY:Range<Int>? = nil
    private(set) var foundationZ:Range<Int>? = nil
    
    private(set) var foundationPointX:[Int] = []
    private(set) var foundationPointY:[Int] = []
    private(set) var foundationPointZ:[Int] = []
  
    private(set) var foundationType:SceneWorldModel.NodeType
    @Published private(set) var foundationCurrentX:Int? = nil
    @Published private(set) var foundationCurrentY:Int? = nil
    @Published private(set) var foundationCurrentZ:Int? = nil
    
    init(type: SceneWorldModel.NodeType) {
        self.type = type
        self.foundationType = type
    }
    
    func setup(title:String? = nil, text:String? = nil, price:String? = nil, unit:Int = 10) -> MaterialData {
        self.title = title
        self.text = text
        self.price = price
        self.unit = unit
        return self
    }
    
    @discardableResult
    func setFoundation(
        x:Range<Int>? = nil, y:Range<Int>? = nil, z:Range<Int>? = nil,
        pointX:[Int] = [], pointY:[Int] = [], pointZ:[Int] = []
    
    ) -> MaterialData {
        self.foundationX = x
        self.foundationY = y
        self.foundationZ = z
        self.foundationPointX = pointX
        self.foundationPointY = pointY
        self.foundationPointZ = pointZ
        return self
    }
    
    // 변경 pct
    func foundation(x:Float? = nil, y:Float? = nil, z:Float? = nil) -> MaterialData {
        
        if let x = x , let foundationX = self.foundationX {
            self.foundationCurrentX = self.getFoundationValue(range: foundationX, v: x)
        }
        if let y = y , let foundationY = self.foundationY {
            self.foundationCurrentY = self.getFoundationValue(range: foundationY, v: y)
        }
        if let z = z , let foundationZ = self.foundationZ {
            self.foundationCurrentZ = self.getFoundationValue(range: foundationZ, v: z)
        }
        switch self.type {
        case .box(let ox, let oy, let oz, let skin):
            self.foundationType = .box(
                x: Float(self.foundationCurrentX ?? Int(ox)),
                y: Float(self.foundationCurrentY ?? Int(oy)),
                z: Float(self.foundationCurrentZ ?? Int(oz)), skin: skin)
            
            
        case .cylinder(let r, let h, let skin):
            self.foundationType = .cylinder(
                r: r,
                h: Float(self.foundationCurrentZ ?? Int(h)), skin: skin)
        case .cone(let r, let br, let h, let skin):
            self.foundationType = .cone(
                r: r, br: br,
                h: Float(self.foundationCurrentZ ?? Int(h)), skin: skin)
        default : break
        }
        return self
    }
    
    // 변경가능한 int로 변환
    private func getFoundationValue(range:Range<Int>, v:Float) -> Int {
        let l = range.lowerBound
        let r = range.upperBound
        let value = Int(max(Float(l),round(Float(r) * v)))
        let unitValue:Int = Int(round(Double(value)/Double(unit))) * unit
        return unitValue
    }
        
    func createFoundationData() -> MaterialData {
        let data:MaterialData = MaterialData(type: self.foundationType)
            .setup(title: self.title)
            .setFoundation(
                x: self.foundationX == nil ? nil
                : (self.foundationX?.lowerBound ?? 1)..<(self.foundationCurrentX ?? self.foundationX?.upperBound ?? 10),
                y: self.foundationY == nil ? nil
                : (self.foundationY?.lowerBound ?? 1)..<(self.foundationCurrentY ?? self.foundationY?.upperBound ?? 10),
                z: self.foundationZ == nil ? nil
                : (self.foundationZ?.lowerBound ?? 1)..<(self.foundationCurrentZ ?? self.foundationZ?.upperBound ?? 10)
            )
        return data
    }
    
    func getFoundationDescription()->String{
        var value:String = self.title ?? self.text ?? ""
        if let foundation = self.foundationX {
            value += (
                "\n" + SceneWorldModel.NodeAxis.X.name + "("
                + Self.getFoundationDescription(self.foundationCurrentX, max: foundation.upperBound)
                + ")"
            )
        }
        if let foundation = self.foundationY {
            value += (
                "\n" + SceneWorldModel.NodeAxis.Y.name + "("
                + Self.getFoundationDescription(self.foundationCurrentY, max: foundation.upperBound)
                + ")"
            )
        }
        if let foundation = self.foundationZ {
            value += (
                "\n" + SceneWorldModel.NodeAxis.Z.name + "("
                + Self.getFoundationDescription(self.foundationCurrentZ, max: foundation.upperBound)
                + ")"
            )
        }
        return value
    }
}
