//
//  PageHome.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/21.
//
import SwiftUI
import Foundation

struct PageStore: PageView {
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pageObject:PageObject
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var storeModel:StoreModel
    
    let dataModel = DataModel()
    @StateObject var infinityScrollModel:InfinityScrollModel = .init()
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.regular){
            Text("Store").modifier(BoldTextStyle(color: Color.brand.content))
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
                ForEach(self.dataModel.group, id: \.self){ group in
                    Section(
                        header:
                            Text(group).modifier(MediumTextStyle(color: Color.brand.content))
                
                    ){
                        let datas = self.dataModel.getData(group)
                        MaterialGrid(datas: datas){ select in
                            let page:PageObject = PageProvider.getPageObject(.storeItem)
                                .addParam(key: .data, value: select)
                            
                            self.pagePresenter.request = .movePage(page)
                        }
                    }
                }
            }
        }
        .modifier(MatchParent())
        .background(Color.brand.bg)
    }
}

