//
//  PageHome.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/21.
//
import SwiftUI
import Foundation

struct Cart: PageView {
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pageObject:PageObject
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var storeModel:StoreModel
    
    @StateObject var infinityScrollModel = InfinityScrollModel()
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.regular){
            if !self.datas.isEmpty {
                ImageButton(
                    isSelected: false,
                    defaultImage: Asset.icon.add,
                    iconText: self.datas.count.description
                ){_ in
                    self.storeModel.complete()
                    self.pagePresenter.request = .closeAllPopup
                }
                .padding(.horizontal, Dimen.margin.regular)
            }
            
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                axes: .horizontal,
                scrollType: .vertical(),
                marginBottom:Dimen.margin.medium,
                marginHorizontal: Dimen.margin.regular,
                spacing: Dimen.margin.thin,
                isRecycle: true,
                useTracking: false
            ){
                
                ForEach(self.datas){ material in
                    Item(data: material)
                }
            }
            .modifier(MatchHorizontal(height: 60))
        }
       
        .opacity(self.status == .hidden ? 0 : 1)
        .onReceive(self.storeModel.$materials) { materials in
            self.datas = materials
        }
        .onReceive(self.storeModel.$status) { status in
            withAnimation{
                self.status = status
            }
        }
        .onAppear(){
            self.storeModel.setup(hasMaterials: [])
        }
    }
    @State private var datas:[MaterialData] = []
    @State private var status:StoreModel.Status = .hidden
    
    struct Item: PageView {
        @EnvironmentObject var storeModel:StoreModel
        let data:MaterialData
        var body: some View {
            ZStack(alignment: .topTrailing){
                ZStack(){
                    Image(self.data.type.skin ?? "grid")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                    Spacer().modifier(MatchParent()).background(Color.transparent.black45)
                    Text(self.data.getFoundationDescription())
                        .modifier(LightTextStyle(color: Color.app.white))
                        .modifier(MatchParent())
                }
                .frame(width: 60, height: 60)
                .padding(.top, 6)
                .padding(.trailing, 6)
                ImageButton(
                    isSelected: false,
                    defaultImage: Asset.component.button.close,
                    sizeType: .S
                ){_ in
                    self.storeModel.removeMaterial(self.data)
                }
                .background(Color.app.white)
                .clipShape(Circle())
                
            }
        }
    }

    
}

