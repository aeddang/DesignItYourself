//
//  MyFileManager.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 9/2/24.
//

import Foundation
import SceneKit

class MyFileManager:PageProtocol {
    let fileManager = FileManager.default
    let documentPath: URL?
        = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    func saveScene(_ scene:SCNScene)-> String?{
        let fileName = (scene.rootNode.name ?? UUID().uuidString) + ".scn"
        guard let path = documentPath?.appendingPathComponent(fileName) else {return nil}
        if scene.write(to: path, options: nil, delegate: nil) {
            return fileName
        } else {
            return nil
        }
        
    }
    func loadScene(name:String)->SCNScene?{
        guard let path = documentPath?.appendingPathComponent(name) else {return nil}
        guard let sceneData = try? Data(contentsOf: path ) else {return nil}
        let sceneSource = SCNSceneSource(data: sceneData, options: nil)
        return sceneSource?.scene()
    }
    
    
    
}
