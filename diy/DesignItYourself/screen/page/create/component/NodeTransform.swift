//
//  NodeTr.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 8/27/24.
//

import Foundation
import SwiftUI
import SceneKit
import UIKit
import AlertToast

struct NodeTransform : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    var isPortrait:Bool = true
    var body: some View {
        VStack(spacing: Dimen.margin.regular){
            
            ZStack(alignment: .top){
                Spacer().modifier(MatchParent())
                if !self.transformNodes.isEmpty {
                    if self.isPortrait {
                        HStack(spacing: Dimen.margin.thin){
                            self.getTransformBody()
                        }
                    } else {
                        VStack(spacing: Dimen.margin.thin){
                            self.getTransformBody()
                        }
                    }
                   
                } else {
                    Text("No material selected.").modifier(MediumTextStyle(color: Color.brand.subContent))
                }
            }
            self.getNodeControlBody()
        }
        .padding(.all, Dimen.margin.tiny)
        .modifier(MatchParent())
        .toast(isPresenting: self.$showToast){
            AlertToast(type: .regular, title: self.toastMsg)
        }
        .onReceive(self.viewModel.$isMultiSelect) { isMultiSelect in
            self.isMultiSelect = isMultiSelect
        }
        .onReceive(self.viewModel.$selectedNodes) { nodes in
            self.updateSelectNodes(nodes)
        }
    }
    
    @ViewBuilder
    func getNodeControlBody() -> some View {
        HStack(spacing: Dimen.margin.thin){
            if !self.transformNodes.isEmpty {
                if self.isBreakGroup {
                    ImageButton(
                        isSelected: false,
                        defaultImage: Asset.icon.separate,
                        sizeType: .L
                    ){_ in
                        self.viewModel.breakGroup(nodes: self.transformNodes)
                        self.updateSelectNodes(self.transformNodes)
                    }
                    
                }
                if self.isBindingGroup {
                    ImageButton(
                        isSelected: false,
                        defaultImage: Asset.icon.bind,
                        sizeType: .L
                    ){_ in
                        self.viewModel.bindingGroup(nodes: self.transformNodes)
                        self.updateSelectNodes(self.transformNodes)
                    }
                }
                if self.isCreatObject {
                    ImageButton(
                        isSelected: false,
                        defaultImage: Asset.icon.conbine,
                        sizeType: .L
                    ){_ in
                        let name = UUID().uuidString
                        let node = self.viewModel.createObject(nodes: self.transformNodes, name: name)
                        self.viewModel.addNode(node, type: .object(), objectName: node.name)
                    }
                }
                ImageButton(
                    isSelected: false,
                    defaultImage: Asset.icon.trash,
                    sizeType: .L
                ){_ in
                    self.transformNodes.forEach{self.viewModel.removeNode($0)}
                }
            }
            
            Spacer().modifier(MatchHorizontal())
            ImageButton(
                isSelected: false,
                defaultImage: Asset.icon.cubeAll,
                sizeType: .L
            ){_ in
                
                self.viewModel.pickAllNode()
            }
            ImageButton(
                isSelected: false,
                defaultImage: self.isMultiSelect ? Asset.icon.cubes : Asset.icon.cube,
                sizeType: .L
            ){_ in
                self.viewModel.isMultiSelect.toggle()
            }
        }
    }
    
    
    @ViewBuilder
    func getTransformBody() -> some View {
        VStack(spacing: Dimen.margin.thin){
            NodeMoveTransform(
                axis: .X,
                transformNodes: self.transformNodes,
                isBreakGroup: self.isBreakGroup
            )
            NodeMoveTransform(
                axis: .Y,
                transformNodes: self.transformNodes,
                isBreakGroup: self.isBreakGroup
            )
            NodeMoveTransform(
                axis: .Z,
                transformNodes: self.transformNodes,
                isBreakGroup: self.isBreakGroup
            )
        }
        if let node = self.transformNodes.first {
            ForEach(self.transformPropertys, id: \.rawValue) { pro in
                NodePropertyTransform(node: node, property: pro, isPortrait: isPortrait)
            }
        }
    }
    
    
    @State private var transformNodes:[SCNNode] = []
    @State private var transformPropertys:[SceneWorldModel.NodeProperty] = []
    @State private var isMultiSelect:Bool = false
    @State private var isBindingGroup:Bool = false
    @State private var isBreakGroup:Bool = false
    @State private var isCreatObject:Bool = false
    @State private var showToast = false
    @State private var toastMsg:String = ""
    {
        didSet{
            self.showToast = !toastMsg.isEmpty
        }
    }
    
    private func updateSelectNodes(_ nodes:[SCNNode]){
        if nodes.first != nil {
            self.transformNodes = nodes
       } else {
            let all = self.viewModel.getAllNodes()
            self.transformNodes = all
            
        }
        if self.transformNodes.count > 1 {
            self.transformPropertys = []
            var currentGroup:String? = nil
            if self.transformNodes.first(where: { n in
                guard let key = n.name else {return false}
                let keys = key.components(separatedBy: "_")
                if keys.count == 2, let gid = keys.last {
                    if let current = currentGroup {
                        return current != gid
                    } else {
                        currentGroup = gid
                        return false
                    }
                } else {
                    return true
                }
            }) == nil {
                self.isBreakGroup = true
                self.isBindingGroup = false
            } else {
                self.isBindingGroup = true
                self.isBreakGroup = false
            }
            let transformNodes = self.transformNodes
            let isCreatObject = transformNodes.first(where: {
                self.viewModel.getNodeData($0)?.type.isObject == true
            }) == nil
            self.isCreatObject = isCreatObject 
        } else {
            if let select = self.transformNodes.first {
                self.transformPropertys = self.viewModel.getNodeData(select)?.type.hasProperty ?? []
            } else {
                self.transformPropertys = []
            }
            self.isBindingGroup = false
            self.isBreakGroup = false
            self.isCreatObject = false
        }
        
    }
}




struct NodePropertyTransform : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    let node:SCNNode
    let property:SceneWorldModel.NodeProperty
    var isPortrait:Bool = true
    var body: some View {
        VStack(spacing: Dimen.margin.light){
            self.getBody()
        }
    }
    
    @ViewBuilder
    func getBody() -> some View {
        switch property {
        case .rotate :
            NodeRotateTransform(node: node, axis: .X)
            NodeRotateTransform(node: node, axis: .Y)
            NodeRotateTransform(node: node, axis: .Z)
        }
    }
}


