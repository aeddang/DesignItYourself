//
//  PageHome.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/21.
//
import SwiftUI
import Foundation

struct PageHome: PageView {
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pageObject:PageObject
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    @StateObject var sceneWorldModel = SceneWorldModel()
    var body: some View {
        VStack{
            Text("3D")
            SceneWorld()
                .modifier(MatchHorizontal(height: 320))
            NodeTransform()
        }
        .environmentObject(self.sceneWorldModel)
        .modifier(MatchParent())
        //.background(Color.brand.bg)
        .onReceive(self.pagePresenter.$screenOrientation) { orientation in
            //self.isPortrait = orientation.isPortrait
            
        }
        
    }
}


