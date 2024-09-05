//
//  ImageView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct ImageGridView : View, PageProtocol {
    @EnvironmentObject var imageLoader:AsyncImageLoader
    let url:String
    var imageSize:CGSize = .init(width:118, height: 66)
    var gridSize:CGSize = .init(width: 160, height: 90)
    var radius:CGFloat = Dimen.radius.light
    var index:Int = 0
    @State var image:UIImage? = nil
    @State var row:CGFloat = 0
    @State var colum:CGFloat = 0
    @State var originSize:CGSize = .zero
    var body: some View {
        ZStack(alignment: .topLeading){
            Spacer().modifier(MatchParent())
            if let img = self.image {
                Image(uiImage: img)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: self.originSize.width, height: self.originSize.height)
                    .offset(
                        x:-( CGFloat(index % Int(row)) * imageSize.width ),
                        y:-( floor(CGFloat(index) / row) * imageSize.height )
                    )
                    .frame(width: 0, height: 0, alignment: .topLeading)
            }
        }
        .frame(width: imageSize.width, height: imageSize.height)
        .background(Color.app.black)
        .clipShape(RoundedRectangle(cornerRadius: self.radius))
        .overlay(
            RoundedRectangle(cornerRadius: self.radius )
                .strokeBorder( Color.app.white, lineWidth:self.radius )
        )
        .opacity(self.image == nil ? 0 : 1)
        .clipped()
        .onAppear(){
            self.imageLoader.load(url: url, id: self.tag)
        }
        .onDisappear(){
            self.imageLoader.cancel()
        }
        .onReceive(self.imageLoader.$event) { evt in
            guard let  evt = evt else { return }
            switch evt {
            case .asyncComplete(let img, let id) :
                if id != self.tag {return}
                let w = img.size.width
                let h = img.size.height
                self.row = round(w/gridSize.width)
                self.colum = round(h/gridSize.height)
                self.originSize = .init(width:row * imageSize.width, height: colum * imageSize.height)
                self.image = img
                
            default : break
            }
        }
        
    }
    

    
}



