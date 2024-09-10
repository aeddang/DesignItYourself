//
//  PageFactory.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/21.
//
import SwiftUI
import Foundation
extension PageID{
    static let home:PageID = "home"
    static let store:PageID = "store"
    static let storeItem:PageID = "storeItem"
    static let storeFoundation:PageID = "storeFoundation"
}

struct PageFactory{
    static func getPage(_ pageObject:PageObject) -> some View{
        switch pageObject.pageID {
        case .store : return PageStore().contentBody
        case .storeItem : return PageStoreItem().contentBody
        case .storeFoundation : return PageStoreFoundation().contentBody
        default : return PageHome().contentBody
        }
    }
    
    static func getPageOrientationMask(_ pageObject:PageObject) -> UIInterfaceOrientationMask{
        switch pageObject.pageID {
        default : return .all
        }
    }
    static func getPageTitle(_ pageObject:PageObject) -> String{
        let customTitle = pageObject.getPageTitle()
        if customTitle.isEmpty == false {return customTitle}
        switch pageObject.pageID {
        default : return ""
        }
    }
    static func useBackButton(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        default : return pageObject.isPopup
        }
    }
}

struct PageProvider {
    
    static func getPageObject(_ pageID:PageID, isPopup:Bool = true)-> PageObject {
        let isHome = isHome(pageID)
        let pobj = PageObject(
            pageID: pageID,
            isPopup: isHome ? false : isPopup,
            isHome: isHome
        )
        return pobj
    }
    static func isHome(_ pageID:PageID)-> Bool{
        switch pageID {
        case .home : return  true
        default : return  false
        }
    }
}
