//
//  ApiManager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Combine
enum ApiStatus{
    case initate, ready, reflash, error
}
enum ApiEvent{
    case initate, error, join
}

struct ApiNetwork :Network{
    static fileprivate(set) var accesstoken:String? = nil
    static func reset(){
        Self.accesstoken = nil
    }
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath()
    func onRequestIntercepter(request: URLRequest)->URLRequest{
        guard let token = ApiNetwork.accesstoken else { return request }
        var authorizationRequest = request
        authorizationRequest.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        authorizationRequest.addValue(SystemEnvironment.preferredLang ?? "", forHTTPHeaderField: "Accept-Language")
        authorizationRequest.addValue("IOS", forHTTPHeaderField: "User-Agent")
        authorizationRequest.addValue(SystemEnvironment.zoneOffset.description, forHTTPHeaderField: "X-Timezone-Offset")
        DataLog.d("token " + token , tag: self.tag)
        return authorizationRequest
    }
    func onDecodingError(data: Data, e:Error) -> Error{
        guard let error = try? self.decoder.decode(ApiErrorResponse.self, from: data) else { return e }
        return ApiError(response: error)
    }
}

struct GoogleApiNetwork :Network{
    static fileprivate(set) var accesstoken:String? = nil
    static func reset(){
        Self.accesstoken = nil
    }
    var enviroment: NetworkEnvironment = "https://maps.googleapis.com/maps/api/"
    /*
    func onRequestIntercepter(request: URLRequest)->URLRequest{
        guard let token = ApiNetwork.accesstoken else { return request }
        var authorizationRequest = request
        authorizationRequest.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        authorizationRequest.addValue(SystemEnvironment.preferredLang ?? "", forHTTPHeaderField: "Accept-Language")
        authorizationRequest.addValue("IOS", forHTTPHeaderField: "User-Agent")
        authorizationRequest.addValue(SystemEnvironment.zoneOffset.description, forHTTPHeaderField: "X-Timezone-Offset")
        DataLog.d("token " + token , tag: self.tag)
        return authorizationRequest
    }
    */
    func onDecodingError(data: Data, e:Error) -> Error{
        guard let error = try? self.decoder.decode(ApiErrorResponse.self, from: data) else { return e }
        return ApiError(response: error)
    }
    
    
}


class ApiManager :PageProtocol, ObservableObject{
    let network:Network = ApiNetwork()
    
    @Published var status:ApiStatus = .initate
    @Published var event:ApiEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published var result:ApiResultResponds? = nil {didSet{ if result != nil { result = nil} }}
    @Published var error:ApiResultError? = nil {didSet{ if error != nil { error = nil} }}
    
    private var anyCancellable = Set<AnyCancellable>()
    private var apiQ :[ ApiQ ] = []
    private var transition = [String : ApiQ]()
    
    //page Api
    let user:UserApi
    
    
    init() {
        self.user = UserApi(network: self.network)
       
    }
    
    func clear(){
        if self.status == .initate {return}
        self.user.clear()
        self.apiQ.removeAll()
    }
    
    func clearApi(){
        ApiNetwork.accesstoken = nil
        self.status = .initate
    }
    
    func initateApi(token:String){
        ApiNetwork.accesstoken = token
        self.status = .ready
        if self.status != .reflash {
            self.event = .initate
        }
        self.executeQ()
    }
    
    
    
    private func executeQ(){
        self.apiQ.forEach{ q in self.load(q: q)}
        self.apiQ.removeAll()
    }
    
    func load(q:ApiQ){
        self.load(q.type, resultId: q.id, isOptional: q.isOptional, isProcess: q.isProcess)
    }
    
    @discardableResult
    func load(_ type:ApiType, resultId:String = "", isOptional:Bool = false, isLock:Bool = false, isProcess:Bool = false)->String {
        let apiID = resultId //+ UUID().uuidString
        _ = {err in self.onError(id: apiID, type: type, e: err, isOptional: isOptional, isLock: isLock,  isProcess: isProcess)}
        
        if status != .ready{
            self.apiQ.append(ApiQ(id: resultId, type: type, isOptional: isOptional, isLock: isLock, isProcess: isProcess))
            return apiID
        }
        /*
        switch type {
        case .getUserDetail(let userId) :
            self.user.get(userId: userId,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        
        default: break
        }
        */
        return apiID
    }
    
    private func complated(id:String, type:ApiType, res:Blank){
        let result:ApiResultResponds = .init(id: id, type:type, data: res)
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = .init(id: id, type:type, data: res)
        }
    }
    private func complated(id:String, type:ApiType, res:[String:Any]){
        guard let status = res["status"] as? String else { return }
        if status != "200" {
            do{
                let data = try JSONSerialization.data(withJSONObject: res, options: .init())
                guard let error = try? JSONDecoder().decode(ApiErrorResponse.self, from: data) else {
                    self.onError( id: id, type: type, e: ApiError(response: ApiErrorResponse.getUnknownError()))
                    return
                }
                return self.onError( id: id, type: type, e: ApiError(response: error))
            } catch {
                self.onError( id: id, type: type, e: error)
            }
            
        }
        self.result = .init(id: id, type:type, data: res)
    }
    private func complated<T:Decodable>(id:String, type:ApiType, res:ApiContentResponse<T>){
        let result:ApiResultResponds = .init(id: id, type:type, data: res.contents)
        
        switch type {
        default : break
        }
        
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = result
        }
    }
    
    private func complated<T:Decodable>(id:String, type:ApiType, res:ApiItemResponse<T>){
        let result:ApiResultResponds = .init(id: id, type:type, data: res.items)
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = result
        }
    }
    
    private func onError(id:String, type:ApiType, e:Error, isOptional:Bool = false, isLock:Bool = false, isProcess:Bool = false){
        if let err = e as? ApiError {
            if let res = err.response {
                switch type {
                default : break
                }
                
                switch res.code {
                default : break
                }
                
            }
        }
        if let trans = transition[id] {
            transition.removeValue(forKey: id)
            self.error = .init(id: id, type:trans.type, error: e, isOptional:isOptional, isProcess:isProcess)
        }else{
            self.error = .init(id: id, type:type, error: e, isOptional:isOptional, isProcess:isProcess)
        }
    }

}
