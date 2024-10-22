//
//  NodeMoveTransform.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 10/22/24.
//
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

struct NodeMoveTransform : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    let axis:SceneWorldModel.NodeAxis
    var transformNodes:[SCNNode]
    var isBreakGroup:Bool
    var body: some View {
        HStack(spacing: Dimen.margin.micro){
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.rectArrow,
                sizeType: .L,
                iconDegrees: -180,
                defaultColor: axis.color
            ){_ in
                
                switch axis {
                case .X: self.transformNodes.forEach{$0.moveX(-100)}
                case .Y: self.transformNodes.forEach{$0.moveY(-100)}
                case .Z: self.transformNodes.forEach{$0.moveZ(-100)}
                }
            }
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.rectArrow,
                sizeType: .L,
                iconDegrees: -180,
                defaultColor: axis.color.opacity(0.7)
            ){_ in
                
                switch axis {
                case .X: self.transformNodes.forEach{$0.moveX(-10)}
                case .Y: self.transformNodes.forEach{$0.moveY(-10)}
                case .Z: self.transformNodes.forEach{$0.moveZ(-10)}
                }
            }
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.rectArrow,
                sizeType: .L,
                iconDegrees: -180,
                defaultColor: axis.color.opacity(0.45)
            ){_ in
                
                switch axis {
                case .X: self.transformNodes.forEach{$0.moveX(-1)}
                case .Y: self.transformNodes.forEach{$0.moveY(-1)}
                case .Z: self.transformNodes.forEach{$0.moveZ(-1)}
                }
            }
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.cross,
                sizeType: .L,
                defaultColor: self.isBreakGroup ? Color.brand.subContent : axis.color
            ){_ in
                
                if self.isBreakGroup { return }
                switch axis {
                case .X: self.transformNodes.forEach{$0.setX()}
                case .Y: self.transformNodes.forEach{$0.setY()}
                case .Z: self.transformNodes.forEach{$0.setZ()}
                }
                
            }
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.rectArrow,
                sizeType: .L,
                defaultColor: axis.color.opacity(0.45)
            ){_ in
                switch axis {
                case .X: self.transformNodes.forEach{$0.moveX(1)}
                case .Y: self.transformNodes.forEach{$0.moveY(1)}
                case .Z: self.transformNodes.forEach{$0.moveZ(1)}
                }
            }
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.rectArrow,
                sizeType: .L,
                defaultColor: axis.color.opacity(0.7)
            ){_ in
                switch axis {
                case .X: self.transformNodes.forEach{$0.moveX(10)}
                case .Y: self.transformNodes.forEach{$0.moveY(10)}
                case .Z: self.transformNodes.forEach{$0.moveZ(10)}
                }
            }
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.rectArrow,
                sizeType: .L,
                defaultColor: axis.color
            ){_ in
                switch axis {
                case .X: self.transformNodes.forEach{$0.moveX(100)}
                case .Y: self.transformNodes.forEach{$0.moveY(100)}
                case .Z: self.transformNodes.forEach{$0.moveZ(100)}
                }
            }
        }
    }
    
}


