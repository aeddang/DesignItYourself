import Foundation
import SwiftUI
import SceneKit
import UIKit

struct NodeScreen : View{
    @EnvironmentObject var viewModel:SceneWorldModel
    
    var type:SceneWorldModel.NodeType
    var userData:SceneWorldModel.UserData? = nil
    let delegate = SceneRendererDelegate()
    var selected: ((SCNNode) -> Void)? = nil

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
        .onTapGesture { location in
            if let result = self.delegate.renderer?.hitTest(
                .init(x: location.x, y: location.y)) {
                if !result.isEmpty, let node = self.item{
                    self.selected?(node)
                }
            }
        }
        .onChange(of: self.type){ 
            self.update()
        }
        .onAppear(){
            let directionalLightNode: SCNNode = {
                let n = SCNNode()
                n.light = SCNLight()
                n.light!.type = SCNLight.LightType.ambient
                n.light!.color = UIColor(white: 0.75, alpha: 0.1)
                return n
            }()

            directionalLightNode.simdPosition = simd_float3(0,5,0) // Above the scene
            directionalLightNode.simdOrientation = simd_quatf(
                angle: -90 * Float.pi / 180.0,
                axis: simd_float3(1,0,0)
            )
            scene.rootNode.addChildNode(directionalLightNode)
            cameraNode.camera = SCNCamera()
            scene.rootNode.addChildNode(cameraNode)
            
            self.update()
        }
        
    }
   
    @State var scene:SCNScene = SCNScene()
    @State var cameraNode:SCNNode = SCNNode()
    @State var item:SCNNode? = nil
    
    private func update(){
        self.item?.removeFromParentNode()
        
        let item:SCNNode = self.userData == nil
        ? self.viewModel.createNode(type: self.type)
        : self.viewModel.createNode(userData: self.userData!)
        
        item.setOrientationY(90).moveRotation(45, x: 1).moveRotation(45, z: 1)
        self.item = item
        scene.rootNode.addChildNode(item)
        
        if let radius = item.geometry?.boundingSphere.radius {
            cameraNode.simdPosition = simd_float3(0,0,max(5,min(20,radius*2)))
            
        } else {
            var maxRadius:Float = 0
            item.childNodes.forEach{
                let radius:Float = $0.geometry?.boundingSphere.radius ?? 0
                maxRadius = max(radius, maxRadius)
            }
            cameraNode.simdPosition = simd_float3(0,0,maxRadius*4)
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
