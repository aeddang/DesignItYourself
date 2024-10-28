//
//  PageHome.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/21.
//
import SwiftUI
import Foundation

struct PageSaveDatas: PageView {
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pageObject:PageObject
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var storeModel:StoreModel
    
   
    @StateObject var viewModel:ViewModel = .init()
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.regular){
            Text("Save Files").modifier(BoldTextStyle(color: Color.brand.content))
                .padding(.horizontal, Dimen.margin.regular)
            ZStack(alignment: .bottom){
                InfinityScrollView(
                    viewModel: self.viewModel,
                    axes: .vertical,
                    scrollType: .vertical(),
                    marginBottom:Dimen.margin.medium,
                    marginHorizontal: Dimen.margin.regular,
                    spacing: Dimen.margin.thin,
                    isRecycle: true,
                    isList: true,
                    useTracking: false
                ){
                    SavedList(
                        datas: self.datas ?? [])
                    { data in
                        
                    } share: { data in
                        
                    } delete: { data in
                        guard let data = data.originData else {return}
                        self.viewModel.persistenceController.deleteSaveData(data)
                    }
                }
                
                if self.isLoading {
                    CircularSpinner()
                        .padding(.bottom, Dimen.margin.medium)
                } else if self.datas?.isEmpty == true {
                    Text(String.alert.dataEmpty)
                        .modifier(MediumTextStyle(color: Color.brand.subContent))
                        .padding(.bottom, Dimen.margin.medium)
                }
            }
        }
        .modifier(MatchParent())
        .background(Color.brand.bg)
        .onReceive(self.viewModel.$datas){ datas in
            self.datas = datas
        }
        .onReceive(self.viewModel.$isLoading){ isLoading in
            withAnimation{
                self.isLoading = isLoading
            }
        }
        .onAppear(){
            if self.datas == nil{
                self.viewModel.reload()
            }
        }
    }
    @State var datas:[SavedList.Data]? = nil
    @State var isLoading:Bool = false
    class ViewModel:InfinityScrollModel{
        @Published private(set) var datas:[SavedList.Data]? = nil
        let persistenceController:PersistenceController = .init()
        
        override func reload() {
            super.reload()
            self.datas = []
            self.load()
        }
        func load(){
            self.onLoad()
            DispatchQueue.global(qos: .background).async {
                var idx = self.datas?.count ?? 0
                let entitys = self.persistenceController.getSaveDatas(page: self.page, count: self.size)
                let datas:[SavedList.Data] = entitys.map{
                    let data:SavedList.Data = .init().setData($0, idx: idx)
                    idx += 1
                    return data
                }
                DispatchQueue.main.async {
                    self.datas?.append(contentsOf: datas)
                    self.onComplete(itemCount: datas.count)
                }
            }
        }
        
    }
    
}


