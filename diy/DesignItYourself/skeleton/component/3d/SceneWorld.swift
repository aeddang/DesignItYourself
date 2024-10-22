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
                        .autoenablesDefaultLighting
                    ],
                    delegate: self.delegate
                )
                .modifier(MatchParent())
                .background(Color.black)
                .onTapGesture { location in
                    if let result = self.delegate.renderer?.hitTest(
                        .init(x: location.x, y: location.y)) {
                        if !result.isEmpty, let node = result.first?.node {
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
        }
        .modifier(MatchParent())
        .onReceive(self.viewModel.$scene){ scene in
            self.scene = scene
        }
        .onAppear(){
        }
        .onDisappear{
            
        }
    }
    @State var scene:SCNScene? = nil
   
    
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





