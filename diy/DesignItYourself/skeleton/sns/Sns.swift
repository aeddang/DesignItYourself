//
//  Sns.swift
//  Valla
//
//  Created by KimJeongCheol on 2020/12/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

protocol Sns {
    func requestLogin()
    func requestLogOut()
    func getAccessTokenInfo()
    func getUserInfo()
    func requestUnlink()
}

enum SnsType:String{
    case apple, fb, google
    func apiCode() -> String {
        switch self {
            case .apple: return "Apple"
            case .fb: return "Facebook"
            case .google: return "Google"
        }
    }
    var logo:String {
        switch self {
            case .apple: return "apple"
            case .fb: return "facebook"
            case .google: return "google"
        }
    }
    var title:String {
        switch self {
            case .apple: return "Apple"
            case .fb: return "Facebook"
            case .google: return "Google"
        }
    }
    var color:Color {
        switch self {
        case .apple: return Color.black
        case .fb: return  Color.init(red: 53/255, green: 120/255, blue: 229/255)
        case .google: return Color.app.black
        }
    }
    
    static func getType(code:String?) -> SnsType? {
        switch code?.lowercased() {
        case "apple": return .apple
        case "facebook": return .fb
        case "google": return .google
        default : return nil
        }
    }
}

enum SnsStatus{
    case login, logout
}

enum SnsEvent{
    case login, logout, getProfile, getToken, invalidToken, reflashToken, shared
}

struct SnsResponds{
    let event:SnsEvent
    let type:SnsType
    var data:Any? = nil
}
struct SnsError{
    let event:SnsEvent
    let type:SnsType
    var error:Error? = nil
}

struct SnsUser{
    var snsType:SnsType
    var snsID:String
    var snsToken:String
}

struct SnsUserInfo{
    var nickName:String? = nil
    var profile:String? = nil
    var email:String? = nil
}
