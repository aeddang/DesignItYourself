//
//  MyMaterialManager.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 9/24/24.
//

import Foundation
extension StoreModel {
    enum Event{
        case add(MaterialData), remove(MaterialData), selected([MaterialData])
    }
    
    enum Status{
        case view, hidden
    }
}


class StoreModel:ObservableObject, PageProtocol{
    
    @Published private(set) var event:Event? = nil {didSet{ if event != nil { event = nil} }}
    @Published private(set) var status:Status = .hidden
    
    @Published private(set) var hasMaterials:[MaterialData] = []
    @Published private(set) var materials:[MaterialData] = []
    
    func onPageChanged(_ page:PageObject){
        switch page.pageID {
        case .store, .storeItem, .storeFoundation :
            self.status = .view
        default :
            self.status = .hidden
        }
    }
    
    func setup(hasMaterials:[MaterialData], isReset:Bool = true){
        self.hasMaterials = hasMaterials
        if isReset {
            self.materials = []
        }
        self.status = .view
    }
    
    func addMaterial(_ data:MaterialData) -> Bool{
        if self.hasMaterials.first(where: {$0.type == data.type}) != nil {
            return false
        }
        
        if self.materials.first(where: {$0.type == data.type}) != nil {
            return false
        } else {
            self.materials.insert(data, at: 0)
            self.event = .add(data)
            return true
        }
    }
    
    @discardableResult
    func removeMaterial(_ data:MaterialData) -> Bool{
        if let find = self.hasMaterials.firstIndex(where: {$0.type == data.type}) {
            self.hasMaterials.remove(at: find)
            self.event = .remove(data)
            return true
        }
        
        guard let find = self.materials.firstIndex(where: {$0.type == data.type}) else {return false}
        self.materials.remove(at: find)
        self.event = .remove(data)
        return true
    }
    
    func complete(){
        self.hasMaterials.append(contentsOf: self.materials)
        self.event = .selected(self.materials)
        self.materials = []
    }
    
    func close(){
        self.status = .hidden
    }
}
