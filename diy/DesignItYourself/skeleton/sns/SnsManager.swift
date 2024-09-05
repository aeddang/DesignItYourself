//
//  SnsManager.swift
//  Valla
//
//  Created by KimJeongCheol on 2020/12/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class SnsManager: ObservableObject, PageProtocol {
    struct Keys {
        static let type = "snsType"
        static let token = "snsUserToken"
    }
    let defaults = UserDefaults.standard
    private var anyCancellable = Set<AnyCancellable>()
    
    @Published private(set) var currentSnsType:SnsType? = nil
    @Published private(set) var user:SnsUser? = nil
    @Published private(set) var userInfo:SnsUserInfo? = nil
    
    @Published var respond:SnsResponds? = nil
    @Published var error:SnsError? = nil
    
    
    private var currentManager:Sns? = nil
    
    let apple:AppleManager
   // let fb:FaceBookManager
    //let google:GoogleSignManager
    init() {
       
        apple = AppleManager()
        //fb = FaceBookManager()
        //google = GoogleSignManager()
        
        apple.$respond.sink(receiveValue: { res in
            guard let res = res else { return }
            self.onRespond(res)
        }).store(in: &anyCancellable)
        
        apple.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            self.onError(err)
        }).store(in: &anyCancellable)
        /*
        fb.$respond.sink(receiveValue: { res in
            guard let res = res else { return }
            self.onRespond(res)
        }).store(in: &anyCancellable)
        
        fb.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            self.onError(err)
        }).store(in: &anyCancellable)
        
        google.$respond.sink(receiveValue: { res in
            guard let res = res else { return }
            self.onRespond(res)
        }).store(in: &anyCancellable)
        
        google.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            self.onError(err)
        }).store(in: &anyCancellable)
        */
    }
    
    func getManager(type:SnsType? = nil) -> Sns?{
        guard let cType = type ?? currentSnsType else { return nil }
        switch cType {
        case .apple : return apple
        //case .fb : return fb
        default: return nil
        //case .google : return google
        }
    }
    
    private func onRespond(_ res:SnsResponds){
        self.respond = res
        if currentSnsType != nil && res.type != currentSnsType { return }
        switch res.event {
        case .login:
            currentSnsType = res.type
            currentManager = self.getManager()
            user = res.data as? SnsUser
            ComponentLog.d("login " + user.debugDescription , tag: self.tag)
            
        case .logout:
            ComponentLog.d("logout " + currentSnsType.debugDescription , tag: self.tag)
            currentSnsType = nil
            user = nil
            userInfo = nil
            currentManager = nil
            
        case .invalidToken:
            ComponentLog.d("invalidToken " + currentSnsType.debugDescription , tag: self.tag)
            currentSnsType = nil
            user = nil
            userInfo = nil
            currentManager = nil
            
        case .getProfile:
            userInfo = res.data as? SnsUserInfo
            ComponentLog.d("getProfile " + userInfo.debugDescription , tag: self.tag)
            
        case .reflashToken: break
        case .getToken: break
        case .shared : break
        }
    }
        
    private func onError(_ err:SnsError){
        self.error = err
        if currentSnsType != nil && err.type != currentSnsType { return }
        if err.event == .login {
            
        }
    }
    
    func requestLogin(type:SnsType) {
        getManager(type: type)?.requestLogin()
    }
    
    func requestLogOut() {
        currentManager?.requestLogOut()
    }
    func requestAllLogOut() {
        //fb.requestLogOut()
        apple.requestLogOut()
        //google.requestLogOut()
    }
    
    func getAccessTokenInfo() {
        currentManager?.getAccessTokenInfo()
    }
    
    func getUserInfo() {
        currentManager?.getUserInfo()
    }
    
    func requestUnlink() {
        currentManager?.requestUnlink()
    }
    
}
