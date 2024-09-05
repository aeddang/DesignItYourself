//
//  SystemEnvironment.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/08.
//

import Foundation
import UIKit

struct SystemEnvironment {
    static let model:String = AppUtil.model
    static let systemVersion:String = UIDevice.current.systemVersion
    static let deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? UUID.init().uuidString
    static let preferredLang = NSLocale.preferredLanguages.first
    static let isTablet = AppUtil.isPad()
    static let zoneOffset = floor(Double(TimeZone.current.secondsFromGMT()/60)).toInt()
    static let pictureWidth:Double = 420
    static var isReleaseMode:Bool = true
    static var firstLaunch :Bool = false
    static var isTestMode:Bool = false
   
}



