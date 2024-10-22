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
        VStack(alignment: .leading, spacing: Dimen.margin.light){
            if self.isPortrait {
                MyObjects()
                    .padding(.top, Dimen.margin.light)
                MyMaterials()
            }
            HStack(spacing: Dimen.margin.light){
                ZStack(alignment: .topTrailing){
                    SceneWorld()
                    WorldControl()
                    if !self.isPortrait {
                        VStack(alignment: .leading, spacing: 0){
                            Spacer()
                            HStack(spacing: 0){
                                MyObjects()
                                MyMaterials()
                            }
                        }
                    }
                }
                .modifier(MatchHorizontal(height: 320))
                if !self.isPortrait {
                    NodeTransform(isPortrait:false)
                        .padding(.vertical, Dimen.margin.light)
                        .modifier(MatchVertical(width: 240))
                    
                }
            }
            if self.isPortrait {
                NodeTransform()
            }
        }
      
        .environmentObject(self.sceneWorldModel)
        .modifier(MatchParent())
        .background(Color.brand.bg)
        
        .onReceive(self.pagePresenter.$screenOrientation) { orientation in
            self.isPortrait = orientation.isPortrait
        }
        .onAppear(){
            if self.sceneWorldModel.isReady {return}
            self.sceneWorldModel.setupDefault()
            self.sceneWorldModel.viewGrid(isOn: true)
            self.sceneWorldModel.setupCamera(pos: .init(0, 0, 15))
        }
    }
    @State var isPortrait:Bool = true
}


