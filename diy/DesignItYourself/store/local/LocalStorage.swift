//
//  SettingStorage.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/12.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SceneKit

class LocalStorage {
    struct Keys {
        static let VS = "1.000"
        static let initate = "initate" + VS
        static let isReceivePush = "isReceivePush" + VS
        static let retryPushToken = "retryPushToken" + VS
        static let registPushToken = "registPushToken" + VS
    }
    let defaults = UserDefaults.standard

    var initate:Bool{
        set(newVal){
            defaults.set(newVal, forKey: Keys.initate)
        }
        get{
            return defaults.bool(forKey: Keys.initate)
        }
    }
    
    var retryPushToken:String{
        set(newVal){
            defaults.set(newVal, forKey: Keys.retryPushToken)
        }
        get{
            return defaults.string(forKey: Keys.retryPushToken) ?? ""
        }
    }
    
    var registPushToken:String{
        set(newVal){
            defaults.set(newVal, forKey: Keys.registPushToken)
        }
        get{
            return defaults.string(forKey: Keys.registPushToken) ?? ""
        }
    }
    
    var isReceivePush:Bool{
        set(newVal){
            defaults.set(newVal, forKey: Keys.isReceivePush)
        }
        get{
            return defaults.bool(forKey: Keys.isReceivePush)
        }
    }
    
  
}
