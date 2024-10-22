//
//  NodeRotateTransform.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 10/22/24.
//
import Foundation
import SwiftUI
import SceneKit
import UIKit

struct NodeRotateTransform : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    let node:SCNNode
    let axis:SceneWorldModel.NodeAxis
    var body: some View {
        HStack(spacing: Dimen.margin.micro){
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.rectRotateL,
                sizeType: .L,
                iconDegrees: -45,
                defaultColor: axis.color
                
            ){_ in
                switch axis {
                case .X: self.node.moveRotation(45, x:-1)
                case .Y: self.node.moveRotation(45, y:-1)
                case .Z: self.node.moveRotation(45, z:-1)
                }
            }
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.rectRotateL,
                sizeType: .L,
                defaultColor: axis.color.opacity(0.5)
            ){_ in
                switch axis {
                case .X: self.node.moveRotation(x:-1)
                case .Y: self.node.moveRotation(y:-1)
                case .Z: self.node.moveRotation(z:-1)
                }
            }
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.rectRotate,
                sizeType: .L,
                iconDegrees: 45,
                defaultColor: axis.color
            ){_ in
                
                switch axis {
                case .X: self.node.normalX()
                case .Y: self.node.normalY()
                case .Z: self.node.normalZ()
                }
                
            }
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.rectRotateR,
                sizeType: .L,
                defaultColor: axis.color.opacity(0.5)
            ){_ in
                switch axis {
                case .X: self.node.moveRotation(x:1)
                case .Y: self.node.moveRotation(y:1)
                case .Z: self.node.moveRotation(z:1)
                }
            }
            
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.rectRotateR,
                sizeType: .L,
                iconDegrees: 45,
                defaultColor: axis.color
                
            ){_ in
                switch axis {
                case .X: self.node.moveRotation(45, x:1)
                case .Y: self.node.moveRotation(45, y:1)
                case .Z: self.node.moveRotation(45, z:1)
                }
            }
        }
    }
}
