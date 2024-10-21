//
//  PageHome.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/21.
//
import SwiftUI
import Foundation
import SwiftData

struct PageCreate: PageView {
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pageObject:PageObject
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    @StateObject var sceneWorldModel = SceneWorldModel.defaultModel()
    var body: some View {
        VStack{
            MyMaterials()
            MyObjects()
            SceneWorld()
                .modifier(MatchHorizontal(height: 320))
            NodeTransform()
        }
        .environmentObject(self.sceneWorldModel)
        .modifier(MatchParent())
        .onReceive(self.pagePresenter.$screenOrientation) { orientation in
            //self.isPortrait = orientation.isPortrait
            
        }
        
    }
}


