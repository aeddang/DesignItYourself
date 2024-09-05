//
//  CPPipButton.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2022/01/20.
//

import Foundation
import SwiftUI
import AVKit
struct CPPipButton: View{
    var isOn:Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: {
            self.action()
        }) {
            
            Image(uiImage: self.isOn
                  ? AVPictureInPictureController.pictureInPictureButtonStartImage
                  : AVPictureInPictureController.pictureInPictureButtonStopImage)
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color.app.white)
                .scaledToFit()
             
        }
    }
}

    
