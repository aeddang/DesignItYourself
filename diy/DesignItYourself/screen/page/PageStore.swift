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
    
    @StateObject var viewModel = ViewModel()
    @StateObject var infinityScrollModel = InfinityScrollModel()
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
                ForEach(self.viewModel.group, id: \.self){ group in
                    Section(
                        header:
                            Text(group).modifier(MediumTextStyle(color: Color.brand.content))
                
                    ){
                        let datas = self.viewModel.getData(group)
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

extension PageStore {
    class ViewModel:ObservableObject, PageProtocol{
        var group:[String] = ["Wood", "Metal", "Stone", "ETC"]
        
        func getData(_ group:String) -> [MaterialItemData] {
            switch group {
            case "Wood" :
                return [
                    .init(
                        image: "preservativeWood",
                        datas: [
                            .init(type: .box(x: 90, y: 15, z: 3600, skin: "preservativeWood"))
                                .setup(title: "데크(소)", text: "15*95*3600", price: "6,000"),
                            .init(type: .box(x: 120, y: 20, z: 3600, skin: "preservativeWood"))
                                .setup(title: "데크(중)", text: "20*120*3600", price: "5,000"),
                            .init(type: .box(x: 140, y: 25, z: 3600, skin: "preservativeWood"))
                                .setup(title: "데크(대)", text: "25*140*3600", price: "5,000")
                        ]
                    )
                    .setup(title: "방부데크재", text: "재단가능")
                    .setFoundation(z: 1..<3600),
                    
                    .init(
                        image: "preservativeWood",
                        datas: [
                            .init(type: .box(x: 38, y: 38, z: 3600, skin: "preservativeWood"))
                                .setup(title: "2X2", text: "38*38*3600", price: "6,000"),
                            .init(type: .box(x: 89, y: 38, z: 3600, skin: "preservativeWood"))
                                .setup(title: "2X4", text: "89*38*3600", price: "5,000"),
                            .init(type: .box(x: 140, y: 38, z: 3600, skin: "preservativeWood"))
                                .setup(title: "2X6", text: "140*38*3600", price: "5,000")
                        ]
                    )
                    .setup(title: "방부각재", text: "재단가능")
                    .setFoundation(z: 100..<3600),
                    
                    .init(
                        image: "preservativeWood",
                        datas: [
                            .init(type: .box(x: 90, y: 90, z: 3600, skin: "preservativeWood"))
                                .setup(title: "4X4", text: "90*90*3600", price: "6,000"),
                            .init(type: .box(x: 120, y: 120, z: 3600, skin: "preservativeWood"))
                                .setup(title: "5X5", text: "120*120*3600", price: "5,000"),
                            .init(type: .box(x: 140, y: 140, z: 3600, skin: "preservativeWood"))
                                .setup(title: "6X6", text: "140*140*3600", price: "5,000")
                        ]
                    )
                    .setup(title: "방부기둥", text: "재단가능")
                    .setFoundation(z: 100..<3600),
                ]
                
            case "Metal" :
                return [
                    .init(
                        image: "zinc",
                        datas: [
                            .init(type: .box(x: 15, y: 15, z: 6000, skin: "zinc"))
                                .setup(title: "15X15", text: "1.2T~1.5T"),
                            .init(type: .box(x: 20, y: 20, z: 6000, skin: "zinc"))
                                .setup(title: "20X20", text: "1.2T~1.5T"),
                            .init(type: .box(x: 25, y: 25, z: 6000, skin: "zinc"))
                                .setup(title: "25X25", text: "1.2T~1.5T"),
                        ]
                    )
                    .setup(title: "아연각관", text: "재단가능")
                    .setFoundation(z: 100..<6000)
                ]
                
            case "Stone" :
                return [
                    .init(
                        image: "brick_red",
                        datas: [
                            .init(type: .box(x: 90, y: 60, z: 190, skin: "brick_red"))
                                .setup(title: "일반", text: "9*5.7*19", price: nil),
                            .init(type: .box(x: 80, y: 90, z: 230, skin: "brick_red"))
                                .setup(title: "미니슈퍼", text: "9*2*36", price: nil),
                            .init(type: .box(x: 80, y: 90, z: 230, skin: "brick_red"))
                                .setup(title: "슈퍼", text: "9*2*36", price: nil)
                        ]
                    ).setup(title: "적벽돌")
                ]
            
            default :
                return [
                    
                ]
            }
            
        }
        
    }
}

