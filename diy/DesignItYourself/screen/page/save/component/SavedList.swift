import SwiftUI
import Foundation
import UIKit
import CoreLocation

struct SavedList: PageView {
    
    var datas:[Data] = []
    var selected: (_ data:Data) -> Void
    var share: (_ data:Data) -> Void
    var delete: (_ data:Data) -> Void
    var body: some View {
        ForEach(self.datas) { data in
            Item(data: data)
                .onTapGesture {
                    self.selected(data)
                }
                .swipeActions(allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        self.delete(data)
                    } label: {
                        Image(Asset.icon.trash)
                            .resizable()
                            .scaledToFill()
                    }
                    Button(role: .none) {
                        self.share(data)
                    } label: {
                        Image(Asset.icon.share)
                            .resizable()
                            .scaledToFill()
                    }
                    .tint(Color.brand.primary)
                }
        }
    }
    
    class Data:InfinityData, ObservableObject {
        private(set) var image:Image? = nil
        private(set) var title:String? = nil
        private(set) var date:Date? = nil
     
        private(set) var saveId:String? = nil
        private(set) var originData:EntitySaveData? = nil
        func setData(_ entity:EntitySaveData, idx:Int = -1)->Data{
            if let img = entity.image , let uiImg = UIImage(data: img) {
                self.image = Image(uiImage: uiImg)
            }
            self.title = entity.title
            self.date = entity.update
            self.saveId = entity.saveId
            self.originData = entity
            return self
        }
       
    }

    struct Item: PageView {
        let data:Data
        var body: some View {
            HStack(spacing: Dimen.margin.tiny){
                if let img = data.image {
                    img
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
                }
                VStack(alignment: .leading, spacing: Dimen.margin.micro){
                    if let t = data.title {
                        Text(t)
                            .modifier(BoldTextStyle())
                    }
                    
                    if let t = data.date?.toDateFormatter(String.format.dateFormatterYMDHM) {
                        Text(t)
                            .modifier(RegularTextStyle())
                    }
                }
            }
        }
    }
}


