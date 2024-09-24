//
//  PageHome.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/21.
//
import SwiftUI
import Foundation

struct PageStoreItem: PageView {
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pageObject:PageObject
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var storeModel:StoreModel
    
    @StateObject var infinityScrollModel = InfinityScrollModel()
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.regular){
            if let data = self.data {
                MaterialItem(data: data)
                    .padding(.horizontal, Dimen.margin.regular)
                InfinityScrollView(
                    viewModel: self.infinityScrollModel,
                    axes: .vertical,
                    scrollType: .vertical(),
                    marginBottom:Dimen.margin.medium,
                    marginHorizontal: Dimen.margin.regular,
                    spacing: Dimen.margin.thin,
                    isRecycle: true,
                    useTracking: false
                ){
                    ForEach(data.datas){ material in
                        Button(action: {
                            self.selected(material)
                        }) {
                            Material(data: material)
                        }
                    }
                }
            }
        }
        .modifier(MatchParent())
        .background(Color.brand.bg)
        .onAppear(){
            if let data = self.pageObject.getParamValue(key: .data) as? MaterialItemData {
                self.data = data
            }
        }
    }
    @State var data:MaterialItemData? = nil
    
    private func selected(_ data:MaterialData){
        let page:PageObject = PageProvider.getPageObject(.storeFoundation)
            .addParam(key: .data, value: data)
        self.pagePresenter.request = .movePage(page)
    }
}

