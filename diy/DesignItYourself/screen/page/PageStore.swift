//
//  PageHome.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/21.
//
import SwiftUI
import Foundation
import Photos
import PhotosUI
import MapKit
import SwiftData

struct PageStore: PageView {
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pageObject:PageObject
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    @StateObject var sceneWorldModel = SceneWorldModel()
    var body: some View {
        VStack{
            Text("Store")
            
        }
        .environmentObject(self.sceneWorldModel)
        .modifier(MatchParent())
        
    }
}

extension PageStore {
    class ViewModel:ObservableObject, PageProtocol{
        var group:[String] = ["Wood", "Metal", "PVC", "ETC"]
        
        func getData(_ group:String) -> [MaterialItemData] {
            switch group {
            case "Wood" :
                return [
                    .init(
                        image: "preservativeWood",
                        datas: [
                            .init(type: .box(x: 12, y: 2, z: 360, skin: "preservativeWood"))
                                .setup(title: "방부목", text: "12*2*36", price: "6,000"),
                            .init(type: .box(x: 12, y: 2, z: 360, skin: "preservativeWood"))
                                .setup(title: "방부목", text: "9*2*36", price: "5,000"),
                            .init(type: .box(x: 4, y: 4, z: 360, skin: "preservativeWood"))
                                .setup(title: "방부목 각재", text: "12*2*36", price: "5,000"),
                            .init(type: .box(x: 16, y: 16, z: 360, skin: "preservativeWood"))
                                .setup(title: "방부목 각재", text: "12*2*36", price: "7,000"),
                        ]
                    ).setup(title: "방부목", text: "재단가능")
                    
                ]
            case "Metal" :
                return [
                    .init(
                        image: "zinc",
                        datas: [
                            .init(type: .box(x: 12, y: 2, z: 360, skin: "zinc"))
                                .setup(title: "아연각관", text: "12*12*18", price: "16,000"),
                            .init(type: .box(x: 12, y: 2, z: 360, skin: "preservativeWood"))
                                .setup(title: "아연각관", text: "9*2*36", price: "5,000"),
                            .init(type: .box(x: 4, y: 4, z: 360, skin: "preservativeWood"))
                                .setup(title: "방부목 각재", text: "12*2*36", price: "5,000"),
                            .init(type: .box(x: 16, y: 16, z: 360, skin: "preservativeWood"))
                                .setup(title: "방부목 각재", text: "12*2*36", price: "7,000"),
                        ]
                    ).setup(title: "아연각관", text: "재단가능")
                    
                ]
            case "PVC" :
                return [
                    .init(image: <#T##String#>, datas: <#T##[MaterialData]#>)
                    
                ]
            default :
                return [
                    .init(image: <#T##String#>, datas: <#T##[MaterialData]#>)
                    
                ]
            }
            
        }
        
    }
}

