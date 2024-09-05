//
//  CustomSwitch.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/26.
//

import Foundation
import SwiftUI
import SceneKit
import UIKit

struct NodeStore : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    var body: some View {
        HStack(){
            NodeStoreItem(type: .box(x:3, skin: "preservativeWood"))
            NodeStoreItem(type: .sphere(r:5, skin: "zinc"))
            NodeStoreItem(type: .cylinder())
            NodeStoreItem(type: .cone())
        }
        .modifier(MatchParent())
        ScrollView(.horizontal){
            LazyHStack{
                ForEach(self.objects){obj in
                    NodeStoreItem(type: obj.type, userData: obj)
                        .modifier(MatchVertical(width: 80))
                }
            }
        }
        .modifier(MatchParent())
        .onReceive(self.viewModel.$objectNodeDatas) { nodes in
            self.objects = nodes.compactMap{$0.value}
        }
    }
   
    @State var objects:[SceneWorldModel.UserData] = []
}

struct NodeStoreItem : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    
    let type:SceneWorldModel.NodeType
    var userData:SceneWorldModel.UserData? = nil
    let delegate = SceneRendererDelegate()
    
    @State var scene:SCNScene = SCNScene()
    @State var item:SCNNode? = nil
    var body: some View {
        SceneView(
            scene: scene,
            options: [
                .allowsCameraControl,
                .autoenablesDefaultLighting,
                .temporalAntialiasingEnabled
            ],
            delegate: self.delegate
        )
        .modifier(MatchParent())
        .background(Color.black)
        .onTapGesture { location in
            if let result = self.delegate.renderer?.hitTest(
                .init(x: location.x, y: location.y)) {
                if !result.isEmpty, let node = self.item{
                    let add = node.clone()
                    let tx = Int.random(in: 15..<30)
                    let ty = Int.random(in: 15..<30)
                    self.viewModel.addNode(
                        add, type: self.type,
                        objectName: self.type.name
                    )
                    add.moveX(Float(-tx)).moveY(Float(ty)).normalY()
                    self.viewModel.removeAllPickNode(exception: add)
                }
            }
        }
        .onAppear(){
            let directionalLightNode: SCNNode = {
                let n = SCNNode()
                n.light = SCNLight()
                n.light!.type = SCNLight.LightType.directional
                n.light!.color = UIColor(white: 0.75, alpha: 1.0)
                return n
            }()

            directionalLightNode.simdPosition = simd_float3(0,3,0) // Above the scene
            directionalLightNode.simdOrientation = simd_quatf(
                angle: -90 * Float.pi / 180.0,
                axis: simd_float3(1,0,0)
            )
            scene.rootNode.addChildNode(directionalLightNode)
    
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.simdPosition = simd_float3(0,0,2.3)
            scene.rootNode.addChildNode(cameraNode)
            let item:SCNNode = self.userData == nil 
            ? self.viewModel.createNode(type: self.type)
            : self.viewModel.createNode(userData: self.userData!)
            item.setOrientationZ(15)
            self.item = item
            scene.rootNode.addChildNode(item)
            
            if let radius = item.geometry?.boundingSphere.radius {
                cameraNode.simdPosition = simd_float3(0,0,radius*3)
            } else {
                var maxRadius:Float = 0
                item.childNodes.forEach{
                    let radius:Float = $0.geometry?.boundingSphere.radius ?? 0
                    maxRadius = max(radius, maxRadius)
                }
                cameraNode.simdPosition = simd_float3(0,0,maxRadius*4)
            }
        }
    }
   
    class SceneRendererDelegate: NSObject, SCNSceneRendererDelegate {
        var renderer: SCNSceneRenderer?
        var onEachFrame: (() -> ())? = nil
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            if self.renderer == nil {
                self.renderer = renderer
            }
        }
    }
}





