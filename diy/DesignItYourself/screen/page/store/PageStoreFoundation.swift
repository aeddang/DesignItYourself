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
    @EnvironmentObject var storeModel:StoreModel
    
    @StateObject var sceneWorldModel = SceneWorldModel()
    var body: some View {
        Group{
            if let data = self.data {
                MaterialFoundation(
                    data: data,
                    orientation: self.isPortrait ? .portrait : .landscapeLeft,
                    pick: {self.pick(data)},
                    completed: {self.completed(data)}
                )
                .modifier(MatchParent())
                .padding(.horizontal,  Dimen.margin.regular)
            }
        }
        .modifier(MatchParent())
        .background(Color.brand.bg)
        .environmentObject(self.sceneWorldModel)
        .onReceive(self.pagePresenter.$screenOrientation) { orientation in
            self.isPortrait = orientation.isPortrait
            
        }
        .onAppear(){
            self.isPortrait = self.pagePresenter.screenOrientation.isPortrait
            if let data = self.pageObject.getParamValue(key: .data) as? MaterialData {
                self.data = data
            }
        }
    }
    @State private var data:MaterialData? = nil
    @State private var isPortrait:Bool = true
    
    private func pick(_ data:MaterialData){
        if self.storeModel.addMaterial(data.createFoundationData()) {
            
        } else {
            DialogHandler.alert(
                message: String.alert.existMaterial,
                confirm: {}
            )
        }
    }
    private func completed(_ data:MaterialData){
        let actions:[UIAlertAction] = [
            UIAlertAction(title: String.app.yes, style: .default, handler: {_ in
                if self.storeModel.addMaterial(data.createFoundationData()) {
                    self.storeModel.complete()
                    self.pagePresenter.request = .closeAllPopup
                    
                } else {
                    DialogHandler.alert(
                        message: String.alert.existMaterial,
                        confirm: {}
                    )
                }
            }),
            UIAlertAction(title: String.app.no, style: .default, handler: {_ in
                self.storeModel.complete()
                self.pagePresenter.request = .closeAllPopup
            })
        ]
        DialogHandler.alert(
            message: String.alert.includeSelectedMaterial,
            actions: actions
        )
    }
    
}

