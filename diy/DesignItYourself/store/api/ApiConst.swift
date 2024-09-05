//
//  ApiConst.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import AVFAudio

struct ApiPath {
    static func getRestApiPath() -> String {
        if SystemEnvironment.isReleaseMode {
            return "https://api.bero.dog/"
        }
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                return dict["RestApiPath"] as? String ?? ""
            }
        }
        return ""
    }
}

struct ApiConst {
    static let pageSize = 12
}

struct ApiCode {
    static let error = "E001"
    static let unknownError = "E999"
}

enum ApiAction:String{
    case login
}

enum ApiValue:String{
    case video
}
      
enum ApiType{
    case getUserDetail(userId:String)
    
    func coreDataKey() -> String? {
        switch self {
        /*
        case .getCode(let category, let searchKeyword) :
            if searchKeyword?.isEmpty == false {return nil}
            else { return category.apiCoreKey }
        */
        default : return nil
        }
    }
    func transitionKey() -> String {
        switch self {
        default : return ""
        }
    }
}
