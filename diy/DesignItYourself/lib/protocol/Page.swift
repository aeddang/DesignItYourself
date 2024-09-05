//
//  Page.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/18.
//
import SwiftUI
import Foundation
protocol PageProtocol {}
extension PageProtocol {
    var tag:String {
        get{ "\(String(describing: Self.self))" }
    }
}


typealias PageID = String
typealias PageParam = String

extension PageParam{
    static let title:String = "title"
    static let id:String = "id"
    static let data:String = "data"
}

enum PageAnimationType {
    case none, vertical, horizontal, opacity
    case reverseVertical, reverseHorizontal
}

class PageObject : ObservableObject, Equatable, Identifiable, Hashable{
    let id:String = UUID().uuidString
    let pageID: PageID
    let isPopup:Bool
    let isHome:Bool
    private(set) var params:[PageParam:Any]?
    
    init(
        pageID:PageID,
        params:[PageParam:Any]? = nil,
        isPopup:Bool = false,
        isHome:Bool = false
    ){
        self.pageID = pageID
        self.params = params
        self.isPopup = isPopup
        self.isHome = isHome
    }
    
    @discardableResult
    func addParam(key:PageParam, value:Any?)->PageObject{
        guard let value = value else { return self }
        if params == nil {
            params = [PageParam:Any]()
        }
        params![key] = value
        return self
    }
    @discardableResult
    func removeParam(key:PageParam)->PageObject{
        if params == nil { return self }
        params![key] = nil
        return self
    }
    @discardableResult
    func addParam(params:[PageParam:Any]?)->PageObject{
        guard let params = params else {
            return self
        }
        if self.params == nil {
            self.params = params
            return self
        }
        params.forEach{
            self.params![$0.key] = $0.value
        }
        return self
    }
    
    func getParamValue(key:PageParam)->Any?{
        if params == nil { return nil }
        return params![key]
    }
    func getPageTitle()->String{
        if params == nil { return "" }
        return params![.title] as? String ?? ""
    }
    
    public static func isSamePage(l:PageObject?, r:PageObject?)-> Bool {
        guard let l = l else {return false}
        guard let r = r else {return false}
        if !l.isPopup && !r.isPopup {
            let same = l.pageID == r.pageID
            return same
        }
        return l.id == r.id
    }
    public static func == (l:PageObject, r:PageObject)-> Bool {
        return l.id == r.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(pageID)
    }
}

enum PageRequest {
    case movePage(PageObject)
    case showModal(PageObject), closeModal
    case closeAllPopup, closePopup
}

class PagePresenter:ObservableObject, PageProtocol{
    @Published private(set) var currentPage:PageObject? = nil
    @Published private(set) var currentTopPage:PageObject? = nil
    
    @Published var request:PageRequest? = nil
    @Published var isLoading:Bool = false
    @Published var isLock:Bool = false
    private var pageCount:Int = 0
    private var finalAddedPage:PageObject? = nil
    
    @Published var screenOrientation:UIDeviceOrientation = .portrait
    @Published var screenSize:CGSize = .zero
    var screenEdgeInsets:EdgeInsets = .init()
    
    @discardableResult
    func updatedPage(_ page:PageObject, count:Int = 0)->PageObject?{
        if page.isHome {
            self.currentPage = page
        }
        self.pageCount += count
        var add:PageObject = page
        switch count {
        case 0 :
            self.currentTopPage = page
            ComponentLog.d("update Page " + page.pageID, tag:self.tag)
            return page
        case 1 :
            self.finalAddedPage = page
        default :
            add = self.finalAddedPage ?? page
        }
        ComponentLog.d("update Page count " + self.pageCount.description, tag:self.tag)
        if self.pageCount != 1 {return nil}
        self.currentTopPage = add
        ComponentLog.d("updated Page " + add.pageID, tag:self.tag)
        return add
    }
    
    
    
    
}
protocol PageViewProtocol : PageProtocol, Identifiable{
    var contentBody:AnyView { get }
}

protocol PageView : View, PageViewProtocol {
    var id:String { get }
    var contentBody:AnyView { get }
}
extension PageView {
    var id:String { get{
        return UUID().uuidString
    }}
    var contentBody:AnyView { get{
        return AnyView(self)
    }}
}

enum ComponentStatus:String {
    case initate,
    active,
    passive ,
    ready ,
    update,
    complete ,
    error,
    end
}

open class ComponentObservable: ObservableObject , PageProtocol, Identifiable{
    @Published var status:ComponentStatus = ComponentStatus.initate
    public let id = UUID().description
}

