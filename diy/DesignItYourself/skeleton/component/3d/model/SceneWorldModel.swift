//
//  SceneWorldModel.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 8/26/24.
//

import Foundation
import SceneKit

class SceneWorldModel:ObservableObject, PageProtocol{
    private(set) static var shared: SceneWorldModel? = nil
    //@Published var status:RepositoryStatus = .initate
    //@Published var event:RepositoryEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published private(set) var objectNodeDatas:[String:UserData] = [:]
    @Published private(set) var nodeDatas:[String:UserData] = [:]
    @Published private(set) var selectedNodes:[SCNNode] = []
    private(set) var groups:[String:[SCNNode]] = [:]
    private let factory = SceneFactory()
    let scene = SCNScene()
    
    init() {
        Self.shared = self
    }
    func createNode(type:NodeType)->SCNNode{
        let node = self.getNode(type: type)
        node.name = UUID().uuidString
        return node
    }
    
    func createObject(nodes:[SCNNode], name:String? = nil)->SCNNode{
        let node = self.getNode(type: .object())
        let n:Float = Float(nodes.count)
        let sumX:Float = nodes.reduce(0, {$0 + $1.simdWorldPosition.x})
        let sumY:Float = nodes.reduce(0, {$0 + $1.simdWorldPosition.y})
        let sumZ:Float = nodes.reduce(0, {$0 + $1.simdWorldPosition.z})
        let mx = sumX/n
        let my = sumY/n
        let mz = sumZ/n
        var historys:[[String]] = []
        nodes.forEach{
            if let udata = self.getNodeData($0) {
                udata.history.insert(udata.type.toString, at: 0)
                historys.append(udata.history)
            }
            self.removeNodeData($0)
            $0.simdWorldPosition.x -= mx
            $0.simdWorldPosition.y -= my
            $0.simdWorldPosition.z -= mz
            $0.opacity = 1
            node.addChildNode($0)
        }
        //node.simdWorldPosition.x = mx
        //node.simdWorldPosition.y = my
        //node.simdWorldPosition.z = mz
        if let name = name {
            node.setName(name)
            let userData:UserData = .init(type: .object(name: name, skin: nil))
            userData.childHistory = historys
            self.objectNodeDatas[name] = userData
        }
        return node
    }
    
    func getNodeData(_ node:SCNNode) -> UserData? {
        guard let key = node.name else {return nil}
        return self.getNodeData(name: key)
    }
    func getNodeData(name:String) -> UserData? {
        guard let id = name.components(separatedBy: "_").first else {return nil}
        return self.nodeDatas[id]
    }
    
    func addHistory(name:String?, value:String) {
        guard let key = name else {return}
        guard let data = self.getNodeData(name: key) else {return}
        data.addHistory(value)
    }
    
    func getAllNodes() -> [SCNNode]{
        return self.scene.rootNode.childNodes.filter{$0.name?.isEmpty == false}
    }
    
    func addNode(_ node:SCNNode, type:NodeType, objectName:String? = nil){
        let key = UUID().uuidString
        node.setName(key)
        var userData:UserData? = nil
        if let name = objectName, let data = self.objectNodeDatas[name] {
            userData = UserData.toUserData(data.toString)
        } else {
            userData = .init(type: type)
        }
        if let data = userData {
            self.nodeDatas[key] = data
        }
        /*
        node.physicsBody = .dynamic()
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.friction = 0
         */
        self.scene.rootNode.addChildNode(node)
    }
    
    func addNode(userDataValue:String){
        guard let data = UserData.toUserData(userDataValue) else {return}
        self.addNode(userData: data)
    }
    func createNode(userData:UserData)->SCNNode{
        var children:[SCNNode] = []
        userData.childHistory.forEach{
            if let cData = UserData.toUserData(values: $0) {
                let cNode = self.getNode(type: cData.type)
                self.addNode(cNode, type: cData.type)
                children.append(cNode)
                cData.history.forEach{ h in
                    cNode.replay(h)
                }
            }
        }
        if !children.isEmpty {
            return self.createObject(nodes: children, name: nil)
        } else {
            return self.getNode(type: userData.type)
        }
    }
    
    func addNode(userData:UserData){
        let key = UUID().uuidString
        let node = self.createNode(userData: userData)
        self.addNode(node, type: userData.type, objectName: userData.type.name)
        userData.history.forEach{ h in
            node.replay(h)
        }
    }
    
    func removeNode(_ node:SCNNode){
        node.removeFromParentNode()
        self.removeNodeData(node)
    }
    
    func removeAllNode(exception:SCNNode? = nil){
        let allNodes = self.getAllNodes()
        allNodes.forEach{
            if $0 != exception {
                self.removeNode($0)
            }
        }
    }
    
    private func removeNodeData(_ node:SCNNode){
        guard let key = node.name else {return}
        let keys = key.components(separatedBy: "_")
        guard keys.first != nil else {return}
        if keys.count == 2, let groupId = keys.last, var group = self.groups[groupId] {
            if let find = group.firstIndex(of: node) {
                group.remove(at: find)
                if group.count <= 1 {
                    self.groups.removeValue(forKey: groupId)
                }
            }
        }
        self.nodeDatas.removeValue(forKey: key)
        if let find = self.selectedNodes.firstIndex(of: node) {
            self.selectedNodes.remove(at: find)
            self.pickNode()
        }
    }

    func pickNode(_ pick:SCNNode? = nil){
        let allNodes = self.getAllNodes()
        if let node = allNodes.first(where: {$0.name == pick?.name}) , let key = node.name {
            var isSelect = false
            let keys = key.components(separatedBy: "_")
            if let find = self.selectedNodes.firstIndex(of: node) {
                isSelect = false
                if keys.count == 1 {
                    self.selectedNodes.remove(at: find)
                }
            } else {
                isSelect = true
                if keys.count == 1 {
                    self.selectedNodes.append(node)
                }
            }
           
            if keys.count == 2, let groupId = keys.last, let group = self.groups[groupId] {
                if isSelect {
                    self.selectedNodes.append(contentsOf: group)
                } else {
                    group.forEach{ n in
                        if let find = self.selectedNodes.firstIndex(of: n) {
                            self.selectedNodes.remove(at: find)
                        }
                    }
                }
            }
        }
        
        if self.selectedNodes.count == allNodes.count {
            self.selectedNodes = []
        }
        if self.selectedNodes.isEmpty {
            allNodes.forEach{$0.opacity = 1}
            DataLog.d("selectedNodes.isEmpty")
        } else {
            allNodes.forEach{$0.opacity = 0.5}
            self.selectedNodes.forEach{$0.opacity = 1}
            DataLog.d("selectedNodes. count" + self.selectedNodes.description)
        }
    }
    func pickAllNode(){
        self.selectedNodes = self.getAllNodes()
        self.pickNode()
    }
    
    func removeAllPickNode(exception:SCNNode? = nil){
        self.selectedNodes = []
        self.pickNode(exception)
    }
    
    func bindingGroup(nodes:[SCNNode]){
        let groupId = UUID().hashValue
        var group:[SCNNode] = []
        nodes.forEach{ n in
            guard let key = n.name else {return}
            let keys = key.components(separatedBy: "_")
            if keys.count == 2, let gid = keys.last {
                self.groups.removeValue(forKey: gid)
            }
            n.name = (keys.first ?? key) + "_" + groupId.description
            group.append(n)
        }
        self.groups[groupId.description] = group
    }
    
    func breakGroup(nodes:[SCNNode]){
        nodes.forEach{ n in
            guard let key = n.name else {return}
            let keys = key.components(separatedBy: "_")
            if keys.count == 2, let gid = keys.last {
                self.groups.removeValue(forKey: gid)
            }
            n.name = (keys.first ?? key)
        }
    }
    
    func getSaveData() -> EntitySaveData? {
        if self.nodeDatas.isEmpty {return nil}
        var json:[String:Any] = [:]
        let nodes = self.nodeDatas.values.map{$0.toString}
        let objects = self.objectNodeDatas.values.map{$0.toString}
        json["nodeDatas"] = nodes
        json["objectNodeDatas"] = objects
        let jsonString = AppUtil.getJsonString(dic: json)
        var saveData = EntitySaveData()
        saveData.data = jsonString
        return saveData
    }
    
    
    class UserData:InfinityData{
        private(set) var type:NodeType = .object()
        fileprivate(set) var history:[String] = []
        fileprivate(set) var childHistory:[[String]] = []
        private(set) var name:String? = nil
        func setName(_ value:String) -> UserData {
            self.name = value
            return self
        }
        init(type: NodeType) {
            self.type = type
        }
        
        func addHistory(_ value:String){
            self.history.append(value)
        }
        func removeHistory(_ value:String? = nil){
            if let v = value {
                if let f = self.history.firstIndex(of: v) {
                    self.history.remove(at: f)
                }
            } else {
                self.history.removeLast()
            }
        }
        //^$*;,  순서
        var toString:String {
            let type = self.type.toString
            let h = history.reduce("", {$0 + ";" + $1})
            if childHistory.isEmpty {
                return type + "^" + h
            }
            let ch = childHistory.reduce("", { c0, c1 in
                c0 + "$" + c1.reduce("", {$0 + "*" + $1})
            })
            return type + "^" + h + "^" + ch
        }
        
        static func toUserData(_ value:String) -> UserData? {
            let div = value.components(separatedBy: "^")
            guard let typeValue = div.first, let type = NodeType.toType(typeValue) else {return nil}
            let userData = UserData(type: type)
            if let historyValue = div[safe:1] {
                let historys = historyValue.components(separatedBy: ";").filter{!$0.isEmpty}
                userData.history = historys
            }
            if let childHistoryValue = div[safe:2] {
                let historys = childHistoryValue.components(separatedBy: "$").filter{!$0.isEmpty}
                let childHistorys = historys.map{$0.components(separatedBy: "*").filter{!$0.isEmpty}}
                userData.childHistory = childHistorys
            }
            return userData
        }
        static func toUserData(values:[String]) -> UserData? {
            guard let typeValue = values.first, let type = NodeType.toType(typeValue) else {return nil}
            let userData = UserData(type: type)
            userData.history = values.dropFirst().map{$0}
            return userData
        }
    }
    enum NodeType:Equatable {
        case box(x:Float = 1, y:Float = 1, z:Float = 1, skin:String? =  nil),
             sphere(r:Float = 1, skin:String? =  nil),
             cylinder(r:Float = 1, h:Float = 1, skin:String? =  nil),
             cone(r:Float = 1, br:Float = 2, h:Float = 1, skin:String? =  nil),
             object(name:String? = nil, skin:String? =  nil)
        var hasProperty:[NodeProperty] {
            switch self {
            case .sphere : return []
            default : return [.rotate]
            }
        }
        
        var isObject:Bool {
            switch self {
            case .object : return true
            default : return false
            }
        }
        var name:String? {
            switch self {
            case .object(let name, _) : return name
            default : return nil
            }
        }
        
        public static func == (l:NodeType, r:NodeType)-> Bool {
            switch (l, r) {
            case ( .box(let x1, let y1, let z1, let skin1), .box(let x2, let y2, let z2, let skin2)):
                if x1 != x2 {return false}
                if y1 != y2 {return false}
                if z1 != z2 {return false}
                if skin1 != skin2 {return false}
                return true
            
            case ( .sphere(let r1, let skin1), .sphere(let r2, let skin2)):
                if r1 != r2 {return false}
                if skin1 != skin2 {return false}
                return true
                
            case ( .cylinder(let r1, let h1, let skin1), .cylinder(let r2, let h2, let skin2)):
                if r1 != r2 {return false}
                if h1 != h2 {return false}
                if skin1 != skin2 {return false}
                return true
            
            case ( .cone(let r1, let br1, let h1, let skin1), .cone(let r2, let br2, let h2, let skin2)):
                if r1 != r2 {return false}
                if br1 != br2 {return false}
                if h1 != h2 {return false}
                if skin1 != skin2 {return false}
                return true
                
            case (.object(let name1, let skin1), .object(let name2, let skin2)):
                if name1 != name2 {return false}
                if skin1 != skin2 {return false}
                return true
            default: return false
            }
        }
        
        var toString:String {
            switch (self) {
            case .box(let x, let y, let z, let skin):
                return "box,x=" + x.description + ",y=" + y.description + ",z=" + z.description
                + ",skin=" + (skin ?? "")
                
            case .sphere(let r, let skin) :
                return "sphere,r=" + r.description
                + ",skin=" + (skin ?? "")
                
            case .cylinder(let r, let h, let skin):
                return "cylinder,r=" + r.description + ",h=" + h.description
                + ",skin=" + (skin ?? "")
                
            case .cone(let r, let br, let h, let skin):
                return "cone,r=" + r.description + ",br=" + br.description + ",h=" + h.description
                + ",skin=" + (skin ?? "")
                
            case .object(let name, let skin):
                return "object,name=" + (name ?? "")
                + ",skin=" + (skin ?? "")
            }
        }
        
        static func toType(_ value:String)-> NodeType? {
            let div = value.components(separatedBy: ",")
            guard let type = div.first else {return nil}
            var values:[String:String] = [:]
            if div.count > 1 {
                div.dropFirst().forEach{
                    let set = $0.components(separatedBy: "=")
                    if set.count == 2, let k = set.first, let v = set.last {
                        values[k] = v
                    }
                }
            }
            switch type {
            case "box" : return .box(
                x: values["x"]?.toFloat() ?? 1 ,
                y: values["y"]?.toFloat() ?? 1 ,
                z: values["z"]?.toFloat() ?? 1 ,
                skin: values["skin"])
            case "sphere" : return .sphere(
                r: values["r"]?.toFloat() ?? 1 ,
                skin: values["skin"])
            case "cylinder" : return .cylinder(
                r: values["r"]?.toFloat() ?? 1 ,
                h: values["h"]?.toFloat() ?? 1 ,
                skin: values["skin"])
            case "cone" : return .cone(
                r: values["r"]?.toFloat() ?? 1 ,
                br: values["br"]?.toFloat() ?? 1 ,
                h: values["h"]?.toFloat() ?? 1 ,
                skin: values["skin"])
                
            case "object" : return .object(
                name: values["name"],
                skin: values["skin"])
            default : return nil
            }
        }
    }
        
    private func getNode(type:NodeType)->SCNNode{
        switch type {
        case .box(let x, let y, let z, let skin) : 
            return self.factory.getBox(x: x,y: y,z: z).updateSkin(named: skin)
        case .cone(let r, let br, let h, let skin) :
            return self.factory.getCone(r:r, br: br, h: h).updateSkin(named: skin)
        case .cylinder(let r, let h, let skin) :
            return self.factory.getCylinder(r:r, h:h).updateSkin(named: skin)
        case .sphere(let r, let skin) : 
            return self.factory.getSphere(r:r).updateSkin(named: skin)
        case .object(let name, let skin):
            return SCNNode().updateSkin(named: skin)
        }
    }
    enum NodeProperty:String {
        case rotate
    }
}
