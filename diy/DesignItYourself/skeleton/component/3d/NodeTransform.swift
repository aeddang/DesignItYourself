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

struct NodeTransform : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    
    var body: some View {
        VStack(){
            if self.isBreakGroup {
                Text("BreakGroup")
                    .onTapGesture {
                        self.viewModel.breakGroup(nodes: self.transformNodes)
                        self.updateSelectNodes(self.transformNodes)
                    }
            }
            if self.isBindingGroup {
                Text("BindingGroup")
                    .onTapGesture {
                        self.viewModel.bindingGroup(nodes: self.transformNodes)
                        self.updateSelectNodes(self.transformNodes)
                    }
            }
            if self.isCreatObject {
                Text("CreatObject")
                    .onTapGesture {
                        let name = UUID().uuidString
                        let node = self.viewModel.createObject(nodes: self.transformNodes, name: name)
                        self.viewModel.addNode(node, type: .object(), objectName: node.name)
                    }
            }
            
            HStack(){
                Text("X")
                    .onTapGesture {
                        self.transformNodes.forEach{$0.setX()}
                    }
                Text("  <<| ").foregroundColor(.white).background(Color.blue)
                    .onTapGesture {
                        self.transformNodes.forEach{$0.moveX(-1)}
                    }
                Text(" |>>  ").foregroundColor(.white).background(Color.blue)
                    .onTapGesture {
                        self.transformNodes.forEach{$0.moveX(1)}
                    }
            }
            HStack(){
                Text("Y")
                    .onTapGesture {
                        self.transformNodes.forEach{$0.setY()}
                    }
                Text("  <<| ").foregroundColor(.white).background(Color.yellow)
                    .onTapGesture {
                        self.transformNodes.forEach{$0.moveY(-1)}
                    }
                Text(" |>>  ").foregroundColor(.white).background(Color.yellow)
                    .onTapGesture {
                        self.transformNodes.forEach{$0.moveY(1)}
                    }
            }
            HStack(){
                Text("Z")
                    .onTapGesture {
                        self.transformNodes.forEach{$0.setZ()}
                    }
                Text("  <<| ").foregroundColor(.white).background(Color.red)
                    .onTapGesture {
                        self.transformNodes.forEach{$0.moveZ(-1)}
                    }
                Text(" |>>  ").foregroundColor(.white).background(Color.red)
                    .onTapGesture {
                        self.transformNodes.forEach{$0.moveZ(1)}
                    }
            }
            if let node = self.transformNodes.first {
                ForEach(self.transformPropertys, id: \.rawValue) { pro in
                    NodePropertyTransform(node: node, property: pro)
                }
                Text("DELETE").foregroundColor(.white).background(Color.red)
                    .onTapGesture {
                        self.transformNodes.forEach{self.viewModel.removeNode($0)}
                    }
                
            }
        }
        .modifier(MatchParent())
        .onReceive(self.viewModel.$selectedNodes) { nodes in
            self.updateSelectNodes(nodes)
        }
    }
    @State var transformNodes:[SCNNode] = []
    @State var transformPropertys:[SceneWorldModel.NodeProperty] = []
    @State var isBindingGroup:Bool = false
    @State var isBreakGroup:Bool = false
    @State var isCreatObject:Bool = false
    
    private func updateSelectNodes(_ nodes:[SCNNode]){
        if let select = nodes.first {
            self.transformNodes = nodes
            if nodes.count > 1 {
                self.transformPropertys = []
                var currentGroup:String? = nil
                if nodes.first(where: { n in
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
        
            } else {
                let pro = self.viewModel.getNodeData(select)?.type.hasProperty
                self.transformPropertys = pro ?? []
                self.isBindingGroup = false
                self.isBreakGroup = false
            }
        } else {
            self.isBindingGroup = false
            self.isBreakGroup = false
            let all = self.viewModel.getAllNodes()
            self.transformNodes = all
            if all.count > 1 {
                self.transformPropertys = []
            } else if let select = all.first {
                self.transformPropertys = self.viewModel.getNodeData(select)?.type.hasProperty ?? []
            } else {
                self.transformPropertys = []
            }
        }
        if self.transformNodes.count > 1 {
            self.isCreatObject = self.transformNodes.first(where: {
                self.viewModel.getNodeData($0)?.type.isObject == true
            }) == nil
        } else {
            self.isCreatObject = false
        }
        
    }
}


struct NodePropertyTransform : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    let node:SCNNode
    let property:SceneWorldModel.NodeProperty
    var body: some View {
        HStack(){
            switch property {
            
            case .rotate :
                Text("RotateX")
                    .onTapGesture {
                        self.node.normalX()
                    }
                Text("<(").foregroundColor(.white).background(Color.cyan)
                    .onTapGesture {
                        self.node.moveRotation(x:-1)
                    }
                Text(")>").foregroundColor(.white).background(Color.cyan)
                    .onTapGesture {
                        self.node.moveRotation(x:1)
                    }
                
                Text("RotateY")
                    .onTapGesture {
                        self.node.normalY()
                    }
                Text("<(").foregroundColor(.white).background(Color.cyan)
                    .onTapGesture {
                        self.node.moveRotation(y:-1)
                    }
                Text(")>").foregroundColor(.white).background(Color.cyan)
                    .onTapGesture {
                        self.node.moveRotation(y:1)
                    }
                
                Text("RotateZ")
                    .onTapGesture {
                        self.node.normalZ()
                    }
                Text("<(").foregroundColor(.white).background(Color.cyan)
                    .onTapGesture {
                        self.node.moveRotation(z:-1)
                    }
                Text(")>").foregroundColor(.white).background(Color.cyan)
                    .onTapGesture {
                        self.node.moveRotation(z:1)
                    }
            }
            
        }
    }
    @State var transformNodes:[SCNNode] = []
    @State var transformPropertys:[SceneWorldModel.NodeProperty] = []
    
}
