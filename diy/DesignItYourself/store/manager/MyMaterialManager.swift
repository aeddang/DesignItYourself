//
//  MyMaterialManager.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 9/24/24.
//

import Foundation
extension MyMaterialManager {
    enum Event{
        case added
    }
}


class MyMaterialManager:ObservableObject, PageProtocol{
    
    @Published var event:Event? = nil {didSet{ if event != nil { event = nil} }}
    
    
    
    
}
