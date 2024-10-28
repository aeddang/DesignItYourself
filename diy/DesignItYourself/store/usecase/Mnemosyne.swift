//
//  Save.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 10/24/24.
//

import Foundation
import Combine
class Mnemosyne: ComponentObservable {
    
    let persistenceController:PersistenceController = .init()
    weak private(set)var storeModel:StoreModel? = nil
    weak private(set)var sceneWorldModel:SceneWorldModel? = nil
    func setup(storeModel:StoreModel?, sceneWorldModel:SceneWorldModel?){
        self.storeModel = storeModel
        self.sceneWorldModel = sceneWorldModel
    }
    deinit{
        self.save()
    }
    var currnetData:EntityCurrentData?{
        return self.persistenceController.getCurrentData()
    }
    func save(){
        guard let sceneWorldModel = self.sceneWorldModel,
              let data = sceneWorldModel.getSaveData() else {return}
        self.saveCurrent(
            data: data,
            items: self.storeModel?.getSaveData()
        )
    }
    
    func saveCurrent(data:String?, items:String?){
        let prevData = self.currnetData
        let entity = prevData ?? self.persistenceController.getEmptyCurrentData()
        entity.data = data
        entity.items = items
        self.persistenceController.writeCurrentData(entity)
    }
    
    func saveData(title:String ,
                  data:String? = nil, items:String? = nil){
        let entity = self.persistenceController.getEmptySaveData()
        entity.title = title
        entity.data = data ?? self.sceneWorldModel?.getSaveData()
        entity.items = items ?? self.storeModel?.getSaveData()
        self.persistenceController.writeSaveData(entity)
    }
    
    func updateData(entity:EntitySaveData , title:String? = nil,
                  data:String? = nil, items:String? = nil){
        if let title = title {
            entity.title = title
        }
        entity.data = data ?? self.sceneWorldModel?.getSaveData()
        entity.items = items ?? self.storeModel?.getSaveData()
        self.persistenceController.updateSaveData(entity)
    }
}
