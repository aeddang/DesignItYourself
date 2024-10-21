import Foundation
import SwiftUI
import SceneKit
import UIKit

struct MyObjects : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    @EnvironmentObject var storeModel:StoreModel
    
    var body: some View {
        VStack{
            ScrollView(.horizontal){
                LazyHStack{
                    ForEach(self.objects){obj in
                        
                        Item(data: obj){ node in
                            let add = node.clone()
                            self.addNode(add, type: obj.type)
                        }
                    }
                }
            }
            .frame(height: 80)
        }
        .modifier(MatchParent())
        .onReceive(self.viewModel.$objectNodeDatas) { nodes in
            self.objects = nodes.compactMap{$0.value}
        }
    }
    @State private var objects:[SceneWorldModel.UserData] = []
    private func addNode(_ node:SCNNode, type:SceneWorldModel.NodeType){
        
        self.viewModel.addNode(
            node, type: type,
            objectName: type.name
        )
        node.normalY()
        self.viewModel.removeAllPickNode(exception: node)
    }
    
    struct Item: PageView {
        @EnvironmentObject var viewModel:SceneWorldModel
        let data:SceneWorldModel.UserData
        var selected: ((SCNNode) -> Void)? = nil
        var body: some View {
            ZStack(alignment: .topTrailing){
                NodeScreen(
                    type: data.type,
                    userData: data,
                    onlyNodeSelect:false,
                    selected: self.selected
                )
                .frame(width: 80, height: 80)
                ImageButton(
                    isSelected: false,
                    defaultImage: Asset.component.button.close,
                    sizeType: .S
                ){_ in
                    self.viewModel.removeObject(data)
                }
                .background(Color.brand.bg)
                .clipShape(Circle())
            }
        }
    }
}





