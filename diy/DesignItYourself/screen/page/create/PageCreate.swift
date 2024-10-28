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
    @EnvironmentObject var storeModel:StoreModel
    @StateObject var sceneWorldModel = SceneWorldModel.defaultModel()
    @StateObject var mnemosyne:Mnemosyne = .init()
    var body: some View {
        
        VStack(alignment: .leading, spacing: Dimen.margin.light){
            if self.isPortrait {
                self.getTop()
                MyObjects()
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
                .modifier(MatchParent())
                if !self.isPortrait {
                    VStack(alignment: .trailing, spacing: Dimen.margin.thin){
                        self.getTop()
                            
                        NodeTransform(isPortrait:false)
                            .padding(.vertical, Dimen.margin.regular)
                            .modifier(MatchParent())
                    }
                    .frame(width: 240)
                }
            }
            if self.isPortrait {
                NodeTransform()
            }
        }
      
        .environmentObject(self.sceneWorldModel)
        .modifier(MatchParent())
        .background(Color.brand.bg)
        .sheet(isPresented:self.$showInputSheet){
            InputSheet(
                origin: Date().toDateFormatter(String.format.dateFormatterYMDHM),
                completed: { text in
                    self.showInputSheet = false
                    guard let text = text else {return}
                    self.mnemosyne.saveData(title: text)
                    
                })
        }
        
        .onReceive(self.pagePresenter.$screenOrientation) { orientation in
            if orientation.isPortrait || orientation.isLandscape {
                self.isPortrait = orientation.isPortrait
            }
        }
        .onWillAppWentToBackground {
            self.mnemosyne.save()
        }
        .onAppear(){
            if self.sceneWorldModel.isReady {return}
            self.sceneWorldModel.setupDefault()
            self.sceneWorldModel.viewGrid(isOn: true)
            self.sceneWorldModel.setupCamera(pos: .init(0, 0, 15))
            self.mnemosyne.setup(
                storeModel: self.storeModel,
                sceneWorldModel: self.sceneWorldModel
            )
            if let prev = self.mnemosyne.currnetData {
                self.storeModel.setSaveData(prev.items)
                self.sceneWorldModel.setSaveData(prev.data)
            }
        }
        .onDisappear{
            //self.mnemosyne.save()
        }
    }
    @State var isPortrait:Bool = true
    @State var showInputSheet:Bool = false
    
    @ViewBuilder
    func getTop() -> some View {
        HStack(spacing: Dimen.margin.thin){
            Spacer().modifier(MatchHorizontal())
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.save,
                sizeType: .L
            ){_ in
                self.showInputSheet = true
            }
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.saveList,
                sizeType: .L
            ){_ in
                
                let page:PageObject = PageProvider.getPageObject(.saveDatas)
                self.pagePresenter.request = .movePage(page)
            }
        }
        .padding(.all, Dimen.margin.tiny)
    }
}


