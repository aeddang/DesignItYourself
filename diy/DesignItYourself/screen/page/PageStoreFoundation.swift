//
//  PageHome.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/21.
//
import SwiftUI
import Foundation

struct PageStoreFoundation: PageView {
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pageObject:PageObject
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    @StateObject var infinityScrollModel = InfinityScrollModel()
    @StateObject var sceneWorldModel = SceneWorldModel()
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.regular){
            if let data = self.data {
                MaterialFoundation(data: data)
                    .padding(.horizontal, Dimen.margin.regular)
            }
        }
        .modifier(MatchParent())
        .background(Color.brand.bg)
        .environmentObject(self.sceneWorldModel)
        .onAppear(){
            if let data = self.pageObject.getParamValue(key: .data) as? MaterialData {
                self.data = data
            }
        }
    }
    @State var data:MaterialData? = nil
    
    private func selected(_ data:MaterialData){
        
    }
}

