//
//  CustomSwitch.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/26.
//

import Foundation
import SwiftUI
import UIKit
struct WorldControl : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    var body: some View {
        HStack(spacing: Dimen.margin.light){
            
            ImageButton(
                isSelected: self.isViewGrid,
                defaultImage:self.isViewGrid ? Asset.icon.gridOn : Asset.icon.gridOff,
                sizeType: .L
            ){_ in
                self.viewModel.viewGrid(isOn: !self.isViewGrid)
            }
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.cameraReset,
                sizeType: .L
            ){_ in
                self.viewModel.resetCamera(pos: .init(0, 0, 15))
            }
            
        }
        .padding(.all, Dimen.margin.regular)
        .onReceive(self.viewModel.$grid){ grid in
            self.isViewGrid = grid != nil
        }
        .background(Color.brand.bg.opacity(0.45))
    }
    @State var isViewGrid:Bool = false
}





