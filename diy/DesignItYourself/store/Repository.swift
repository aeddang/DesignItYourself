//
//  Repository.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import FirebaseAnalytics

class DataProvider : ObservableObject {
    @Published private(set) var request:ApiQ? = nil
        {didSet{ if request != nil { request = nil} }}
    @Published fileprivate(set) var result:ApiResultResponds? = nil
        {didSet{ if result != nil { result = nil} }}
    @Published fileprivate(set) var error:ApiResultError? = nil
        {didSet{ if error != nil { error = nil} }}
    
    func requestData(q:ApiQ){
        self.request = q
    }
}

enum RepositoryStatus{
    case initate, ready
}

enum RepositoryEvent{
    case loginUpdate, messageUpdate(Bool)
}

class Repository:ObservableObject, PageProtocol{
    @Published var status:RepositoryStatus = .initate
    @Published var event:RepositoryEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published private(set) var hasNewAlarm:Bool = false
    let pagePresenter:PagePresenter
    let dataProvider:DataProvider
    let networkObserver:NetworkObserver
    let locationObserver:LocationObserver
    
    private let apiManager = ApiManager()
    let storage = LocalStorage()
    let persistenceController:PersistenceController
    private var anyCancellable = Set<AnyCancellable>()
    private var dataCancellable = Set<AnyCancellable>()
     
    init(
        dataProvider:DataProvider? = nil,
        pagePresenter:PagePresenter? = nil,
        networkObserver:NetworkObserver? = nil,
        locationObserver:LocationObserver? = nil
        
    ) {
        self.dataProvider = dataProvider ?? DataProvider()
        self.networkObserver = networkObserver ?? NetworkObserver()
        self.pagePresenter = pagePresenter ?? PagePresenter()
        self.locationObserver = locationObserver ?? LocationObserver()
        self.persistenceController = PersistenceController()
        self.setupPresenter()
        self.setupSetting()
        self.setupDataProvider()
        self.setupApiManager()
        
    }
    
    deinit {
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
    }
    
    private func setupPresenter(){
        self.pagePresenter.$currentPage.sink(receiveValue: { page in
            guard (page?.pageID) != nil else {return}
            self.apiManager.clear()
            self.pagePresenter.isLoading = false
            self.retryRegisterPushToken()
            
        }).store(in: &anyCancellable)
        
        self.pagePresenter.$currentTopPage.sink(receiveValue: { page in
            guard let page = page else {return}
            let parameters = [
                "pageId": page.pageID
            ]
            let currentSystemScheme = UITraitCollection.current.userInterfaceStyle
            Color.scheme = currentSystemScheme == .dark ? .dark : .light
            Analytics.logEvent(AnalyticsEventScreenView, parameters:parameters)
        }).store(in: &anyCancellable)
    }
    
    private func setupDataProvider(){
        self.dataProvider.$request.sink(receiveValue: { req in
            guard let apiQ = req else { return }
            if apiQ.isLock {
                self.pagePresenter.isLoading = true
            }
            if self.status != .initate, let coreDatakey = apiQ.type.coreDataKey() {
                self.requestApi(apiQ, coreDatakey:coreDatakey)
            }else{
                self.apiManager.load(q: apiQ)
            }
        }).store(in: &anyCancellable)
        
        self.dataProvider.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            if res.id != self.tag { return }
            switch res.type {
            default : break
            }
            
        }).store(in: &anyCancellable)
    }
    
    private func setupSetting(){
        if !self.storage.initate {
            self.storage.initate = true
            self.storage.isReceivePush = true
            SystemEnvironment.firstLaunch = true
            DataLog.d("initate APP", tag:self.tag)
        }
    }
    
    private func setupApiManager(){
        self.apiManager.$event.sink(receiveValue: { evt in
            switch evt {
            default: break
            }
        }).store(in: &dataCancellable)
        
        self.apiManager.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            self.respondApi(res)
            self.dataProvider.result = res
            self.pagePresenter.isLoading = false
        
        }).store(in: &dataCancellable)
        
        self.apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            self.errorApi(err)
            self.dataProvider.error = err
            if !err.isOptional {
               //self.appSceneObserver?.alert = .apiError(err)
            }
            self.pagePresenter.isLoading = false
            
        }).store(in: &dataCancellable)
        
    }
   
    private func requestApi(_ apiQ:ApiQ, coreDatakey:String){
        DispatchQueue.global(qos: .background).async(){
            var coreData:Codable? = nil
            switch apiQ.type {
                /*
                case .getCode :
                    if let savedData:[CodeData] = self.apiCoreDataManager.getData(key: coreDatakey){
                        coreData = savedData
                    }
                */
                default: break
            }
            DispatchQueue.main.async {
                if let coreData = coreData {
                    self.dataProvider.result = ApiResultResponds(id: apiQ.id, type: apiQ.type, data: coreData)
                    self.pagePresenter.isLoading = false
                }else{
                    self.apiManager.load(q: apiQ)
                }
            }
        }
    }
    private func respondApi(_ res:ApiResultResponds){
        switch res.type {
        default : break
        }
        
        if let coreDatakey = res.type.coreDataKey(){
            self.respondApi(res, coreDatakey: coreDatakey)
        }
    }
    
    private func errorApi(_ err:ApiResultError){
        switch err.type {
        default : break
        }
    }
    
    private func respondApi(_ res:ApiResultResponds, coreDatakey:String){
        DispatchQueue.global(qos: .background).async(){
            switch res.type {
            default: break
            }
        }
    }
    
    func setupPush(_ isOn:Bool){
        self.storage.isReceivePush = isOn
        if isOn {
            self.retryRegisterPushToken()
        } else {
            let token = self.storage.registPushToken
            self.storage.registPushToken = ""
            self.storage.retryPushToken = token
            //self.dataProvider.requestData(q: .init(type: .registPush(token: ""), isOptional: true))
            DataLog.d("clear RegisterPushToken " + token, tag:self.tag)
        }
    }
    
    func retryRegisterPushToken(){
        if !self.storage.isReceivePush {
            return
        }
        if !self.storage.retryPushToken.isEmpty{
            DataLog.d("retryRegisterPushToken " + self.storage.retryPushToken, tag:self.tag)
            self.registPushToken(self.storage.retryPushToken)
        }
    }
    func onCurrentPushToken(_ token:String) {
        if !self.storage.isReceivePush {
            self.storage.retryPushToken = token
            return
        }
        if self.storage.registPushToken == token {return}
        DataLog.d("onCurrentPushToken", tag:self.tag)
        switch self.status {
        case .initate :  self.storage.retryPushToken = token
        case .ready : self.registPushToken(token)
        }
    }
    
    private func registPushToken(_ token:String) {
        self.storage.retryPushToken = ""
        self.storage.registPushToken = token
        //self.dataProvider.requestData(q: .init(type: .registPush(token: token), isOptional: true))
    }
    private func registedPushToken(_ token:String) {
        
        DataLog.d("registedPushToken", tag:self.tag)
    }
    private func registFailPushToken(_ token:String) {
        self.storage.retryPushToken = token
        self.storage.registPushToken = ""
        DataLog.d("registFailPushToken", tag:self.tag)
    }
   
}
