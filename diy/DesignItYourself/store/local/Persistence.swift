//
//  Persistence.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 5/20/24.
//

import CoreData

class PersistenceController:PageProtocol{
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    let viewContext: NSManagedObjectContext
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DesignItYourself")
        self.viewContext = self.container.viewContext
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                DataLog.e("Unresolved error \(error), \(error.userInfo)", tag: self.tag)
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func getEmptySaveData()->EntitySaveData{
        return EntitySaveData(context: viewContext)
    }
    
    func getSaveDatas( page:Int? = 0, count:Int = 12)->[EntitySaveData]{
        do {
            let request:NSFetchRequest<EntitySaveData> = .init(entityName: "EntitySaveData")
            if let page = page {
                request.fetchOffset = page * count
                request.fetchLimit = count
            }
            let sortDescriptor = NSSortDescriptor(key: "update", ascending: false)
            request.sortDescriptors = [sortDescriptor]
            let list = try viewContext.fetch(request)
            return list
        } catch {
            let nsError = error as NSError
            DataLog.e("Unresolved error \(nsError), \(nsError.userInfo)", tag: self.tag)
            return []
        }
    }
    
    func writeSaveData(_ data:EntitySaveData, completed:(() -> Void)? = nil){
        DispatchQueue.global(qos: .background).async {
            data.timestamp = Date()
            data.update = Date()
            data.saveId = UUID().uuidString
            self.save()
            DispatchQueue.main.async {
                completed?()
            }
        }
    }
    func updateSaveData(_ data:EntitySaveData, completed:(() -> Void)? = nil){
        DispatchQueue.global(qos: .background).async {
            data.update = Date()
            self.save()
            DispatchQueue.main.async {
                completed?()
            }
        }
    }
    
    func deleteSaveData(_ data:EntitySaveData, completed:(() -> Void)? = nil){
        DispatchQueue.global(qos: .background).async {
            self.viewContext.delete(data)
            self.save()
            DispatchQueue.main.async {
                completed?()
            }
        }
    }
    
    func deleteSaveDatas(_ datas:[EntitySaveData], completed:(() -> Void)? = nil){
        DispatchQueue.global(qos: .background).async {
            datas.forEach{
                self.viewContext.delete($0)
            }
            self.save()
            DispatchQueue.main.async {
                completed?()
            }
        }
    }
    
    func getEmptyCurrentData()->EntityCurrentData{
        return EntityCurrentData(context: viewContext)
    }
    func getCurrentData()->EntityCurrentData?{
        do {
            let request:NSFetchRequest<EntityCurrentData> = .init(entityName: "EntityCurrentData")
            request.fetchOffset = 0
            request.fetchLimit = 1
            let list = try viewContext.fetch(request)
            return list.first
        } catch {
            let nsError = error as NSError
            DataLog.e("Unresolved error \(nsError), \(nsError.userInfo)", tag: self.tag)
            return nil
        }
    }
    
    func writeCurrentData(_ data:EntityCurrentData, completed:(() -> Void)? = nil){
        DispatchQueue.global(qos: .background).async {
            self.save()
            DispatchQueue.main.async {
                completed?()
            }
        }
    }
    
    
    private func save(){
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            DataLog.e("Unresolved error \(nsError), \(nsError.userInfo)", tag: self.tag)
        }
    }
}
