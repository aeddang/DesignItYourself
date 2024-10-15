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
struct SceneWorld : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    let fileManager:MyFileManager = .init()
    var body: some View {
        ZStack(alignment: .topTrailing){
            if let scene = self.scene {
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
                        if !result.isEmpty, let node = result.first?.node {
                        
                            if !self.isMultiSelect {
                                self.viewModel.removeAllPickNode()
                            }
                            self.viewModel.pickNode(node)
                        }
                    }
                }
                .gesture(LongPressGesture(minimumDuration: 1)
                    .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                    .onEnded { value in
                        switch value {
                            case .second(true, let drag):
                            guard let location = drag?.location else {return}
                            if let result = self.delegate.renderer?.hitTest(
                                .init(x: location.x, y: location.y)) {
                                if !result.isEmpty, let node = result.first?.node {
                                    self.viewModel.removeAllPickNode()
                                    self.viewModel.pickNode(node)
                                    
                                }
                            }
                            default:break
                        }
                    })
                
                
            }
            VStack{
                HStack(){
                    Text("SelectALL")
                        .onTapGesture {
                            self.viewModel.pickAllNode()
                        }
                    
                    Text(self.isMultiSelect ? "MultiSelect" : "SingleSelect")
                        .onTapGesture {
                            self.isMultiSelect.toggle()
                        }
                    
                    Text("VX")
                        .onTapGesture {
                            if let camera = self.camera {
                                let move = SCNAction.move(to: .init(x: 30, y: 0, z: 0), duration: 1.0)
                                camera.runAction(move)
                            }
                        }
                    Text("VY")
                        .onTapGesture {
                            if let camera = self.camera {
                                let move = SCNAction.move(to: .init(x: 0, y:30, z: 0), duration: 1.0)
                                camera.runAction(move)
                            }
                        }
                    Text("VZ")
                        .onTapGesture {
                            if let camera = self.camera {
                                let move = SCNAction.move(to: .init(x: 0, y: 0, z: 30), duration: 1.0)
                                camera.runAction(move)
                            }
                        }
                }
                HStack(){
                    Text("Save")
                        .onTapGesture {
                            guard let node = self.viewModel.selectedNodes.first else {return}
                            self.saveData = self.viewModel.getNodeData(node)?.toString
                            self.viewModel.removeNode(node)
                        }
                    Text("Load")
                        .onTapGesture {
                            guard let data = self.saveData else {return}
                            self.viewModel.addNode(userDataValue: data )
                        }
                }
            }
            .background(Color.gray)
        }
        .modifier(MatchParent())
        .onAppear(){
            let scene = self.viewModel.scene
            let directionalLightNode: SCNNode = {
                let n = SCNNode()
                n.light = SCNLight()
                n.light!.type = SCNLight.LightType.directional
                n.light!.color = UIColor(white: 0.75, alpha: 1.0)
                return n
            }()

            directionalLightNode.simdPosition = simd_float3(0,10,0) // Above the scene
            directionalLightNode.simdOrientation = simd_quatf(
                angle: -90 * Float.pi / 180.0,
                axis: simd_float3(1,0,0)
            ) 
            scene.rootNode.addChildNode(directionalLightNode)
    
            let cameraNode = SCNNode()
            let camera = SCNCamera()
            cameraNode.camera = camera
            cameraNode.simdPosition = simd_float3(0,0,10)
            scene.rootNode.addChildNode(cameraNode)
            scene.rootNode.addChildNode(CoordinateGrid())
         
            self.camera = cameraNode
            self.scene = scene
        }
        .onDisappear{
            
        }
    }
    @State var saveData:String? = nil
    @State var scene:SCNScene? = nil
    @State var camera:SCNNode? = nil
    @State var isMultiSelect:Bool = false
    @State var scName:String? = nil
    let delegate = SceneRendererDelegate()
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





