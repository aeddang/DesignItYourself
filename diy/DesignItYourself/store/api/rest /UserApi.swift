//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit

class UserApi :Rest{
    func post(pushToken:String, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["deviceId"] = SystemEnvironment.deviceId
        params["token"] = pushToken
        params["platform"] = "IOS"
        //fetch(route: UserApiRoute (method: .post, action: .pushToken, body: params), completion: completion, error:error)
    }
    
    func delete( completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: UserApiRoute (method: .delete), completion: completion, error:error)
    }
    
    func get(userId:String, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: UserApiRoute (method: .get, commandId: userId), completion: completion, error:error)
    }
    
}

struct UserApiRoute : ApiRoute{
    var method:HTTPMethod = .get
    var command: String = "users"
    var commandId: String? = nil
    var action: ApiAction? = nil
    var actionId: String? = nil
   
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
}

struct UserBlockApiRoute : ApiRoute{
    var method:HTTPMethod = .get
    var command: String = "users/block"
    var commandId: String? = nil
    var action: ApiAction? = nil
    var actionId: String? = nil
   
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
}
