//
//  Api.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation




struct ApiQ :Identifiable{
    var id:String = UUID().uuidString
    let type:ApiType
    var isOptional:Bool = false
    var isLock:Bool = false
    var isProcess:Bool = false
    
    func copy(newId:String? = nil) -> ApiQ {
        let nid = newId ?? id
        return ApiQ(id: nid, type: type,  isOptional: isOptional, isLock: isLock)
    }
}


struct ApiError :Error,Identifiable{
    let id = UUID().uuidString
    var response:ApiErrorResponse? = nil
    
    static func getViewMessage(response:ApiErrorResponse?)->String{
        guard let response = response else {return String.alert.apiErrorServer }
        return (response.error ?? String.alert.apiErrorServer) //+ " - " + response.code
    }
}

struct ApiResultResponds:Identifiable{
    let id:String
    let type:ApiType
    let data:Any
}
struct ApiResultError :Identifiable{
    let id:String
    let type:ApiType
    let error:Error
    var isOptional:Bool = false
    var isProcess:Bool = false
}

struct ApiErrorResponse: Decodable {
    private(set) var status:String?
    private(set) var code: String?
    private(set) var message: String?
    private(set) var error: String?
    
    static func getUnknownError()->ApiErrorResponse{
        return ApiErrorResponse(status: nil, code: ApiCode.unknownError, message: nil, error: nil)
    }
}

struct ApiContentResponse<T>: Decodable where T: Decodable {
    var contents:T
    private(set) var kind: String
    private(set) var metadata: MetaData? = nil
}

struct ApiItemResponse<T>: Decodable where T: Decodable {
    var items:[T]
    private(set) var kind: String
    private(set) var metadata: MetaData? = nil
}

struct MetaData : Decodable {
    private(set) var exp: Double? = nil
    private(set) var point: Int? = nil
    private(set) var level: Int? = nil
    private(set) var nextLevelExp: Double? = nil
    private(set) var prevLevelExp: Double? = nil
}

protocol ApiRoute : NetworkRoute {
    var vs:String { get }
    var command:String { get set }
    var commandId:String? { get set }
    var action:ApiAction? { get set }
    var actionId:String? { get set }
    func defaultSetup() -> ApiRoute
    
}

extension ApiRoute  {
    var vs:String { get{ "v1" } }
    var path: String { get{
        var value = self.vs + "/" + command
        if let id = commandId {
            value = value + "/" + id
        }
        if let ac = action {
            value = value + "/" + ac.rawValue
        }
        if let id = actionId {
            value = value + "/" + id
        }
        return value
    }}
    var commandId:String? { get{ nil } set{ commandId = nil }}
    var action:ApiAction? { get{ nil } set{ action = nil }}
    var actionId:String? { get{ nil } set{ actionId = nil }}
    func defaultSetup() -> ApiRoute { return self}
}


