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
struct SceneWorld : View, PageProtocol{
    @EnvironmentObject var viewModel:SceneWorldModel
    let fileManager:MyFileManager = .init()
    var body: some View {
        Group{
            if let scene = self.sceneView {
                scene
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
                .gesture(
                    LongPressGesture(minimumDuration: 1)
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
            let sceneView = SceneView(
                scene: scene,
                options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled,
                    .rendersContinuously,
                ],
                delegate: self.delegate
            )
            self.sceneView = sceneView
           
        }
       
    }
    @State var scene:SCNScene? = nil
    @State var sceneView:SceneView? = nil
    @State var delegate = SceneRendererDelegate()
    
    class SceneRendererDelegate: NSObject, SCNSceneRendererDelegate, PageProtocol {
        fileprivate var sceneView:SceneView? = nil
        fileprivate var renderer:SCNSceneRenderer? = nil
        fileprivate var onEachFrame: (() -> ())? = nil
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            if self.renderer == nil {
                self.renderer = renderer
            }
            
            //DataLog.d(camera.region.span.longitudeDelta.debugDescription, tag: self.tag)
        }
    }
}





