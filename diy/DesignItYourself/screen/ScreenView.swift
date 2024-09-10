//
//  ContentView.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/07/20.
//

import SwiftUI
import CoreData

class AppSceneObserver:ObservableObject{
    @Published var event:SceneEvent? = nil {didSet{ if event != nil { event = nil} }}
}
enum SceneEvent {
    case test
}

struct ScreenView: View, PageProtocol {
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @StateObject var appSceneObserver:AppSceneObserver = AppSceneObserver()
    let deviceRotateHandler = DeviceRotateHandler()
    @State var stack = NavigationPath()

    var body: some View {
        GeometryReader { geometry in
            ZStack{
                NavigationStack(path: self.$stack) {
                    ZStack{
                        if self.stack.isEmpty {
                            Image(Asset.appLauncher)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .modifier(MatchHorizontal(height: 180))

                        }
                        Spacer()
                            .navigationDestination(for: PageObject.self) { page in
                                PageFactory.getPage(page)
                                    .preferredColorScheme(Color.scheme)
                                    .background(self.bgColor)
                                    .navigationBarBackButtonHidden(!PageFactory.useBackButton(page))
                                    .navigationBarTitleDisplayMode(.automatic)
                                    .navigationTitle(PageFactory.getPageTitle(page))
                                    .environmentObject(page)
                                    .onAppear{
                                        if let current = self.pagePresenter.updatedPage(page, count: 1) {
                                            self.updatePage(current, geometry: geometry)
                                        }
                                    }
                                    .onDisappear{
                                        if let current = self.pagePresenter.updatedPage(page, count: -1) {
                                            self.updatePage(current, geometry: geometry)
                                        }
                                    }
                            }
                    }
                    .modifier(MatchParent())
                    .background(self.bgColor)
                    .sheet(isPresented: self.$showModal) {
                        if let modal = self.currentModal {
                            PageFactory.getPage(modal)
                                .environmentObject(modal)
                                .edgesIgnoringSafeArea(.all)
                        }
                    }
                }
                .accentColor(self.contentColor)
                if self.isLock {
                    Spacer().modifier(MatchParent()).background(Color.transparent.black70)
                }
                if self.isLoading {
                    CircularSpinner()
                }
            }
            .environmentObject(self.appSceneObserver)
            .onReceive(self.pagePresenter.$request){ request in
                guard let request = request else {return}
                switch request {
                case .movePage(let page) :
                    if page.isHome {
                        self.stack = NavigationPath()
                    }
                    self.stack.append( page )
                    self.pagePresenter.updatedPage(page)
                    
                case .closeAllPopup :
                    let count = self.stack.count
                    if count <= 1 {return}
                    let n = self.stack.count-1
                    self.stack.removeLast(n)
                    
                case .closePopup :
                    let count = self.stack.count
                    if count <= 1 {return}
                    self.stack.removeLast()
                case .showModal(let modal) :
                    self.currentModal = modal
                    self.showModal = true
                case .closeModal :
                    self.showModal = false
                }
            }
            
            .onReceive(self.pagePresenter.$isLock){ isLock in
                withAnimation{
                    self.isLock = isLock
                }
            }
            .onReceive(self.pagePresenter.$isLoading){ isLoading in
                withAnimation{
                    self.isLoading = isLoading
                }
            }
            .onReceive(self.orientationChanged){ note in
                guard let device = note.object as? UIDevice else { return }
                if device.orientation.isPortrait || device.orientation.isLandscape {
                    self.pagePresenter.screenOrientation = device.orientation
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                        let size = geometry.size
                        PageLog.d("size " + size.debugDescription,tag: self.tag)
                        self.pagePresenter.screenEdgeInsets = geometry.safeAreaInsets
                        self.pagePresenter.screenSize = geometry.size
                    }
                }
            }
            .onAppCameToForeground {
                self.keyboardObserver.start()
                self.updatedPageColorMode()
            }
            .onAppear(){
                self.updatedPageColorMode()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    let addPage = PageProvider.getPageObject(.store)
                    self.pagePresenter.request = .movePage(addPage)
                }
            }
        }
    }
    
    @State private var showModal:Bool = false
    @State private var currentModal:PageObject? = nil
    @State private var isLoading:Bool = false
    @State private var isLock:Bool = false
    @State private var contentColor:Color = Color.brand.content
    @State private var bgColor:Color = Color.brand.bg
    private func updatedPageColorMode(){
        let currentSystemScheme = UITraitCollection.current.userInterfaceStyle
        Color.scheme = currentSystemScheme == .dark ? .dark : .light
        self.bgColor = Color.brand.bg
        self.contentColor = Color.brand.content
    }

    private func updatePage(_ page:PageObject, geometry:GeometryProxy){
        self.pagePresenter.screenEdgeInsets = geometry.safeAreaInsets
        self.pagePresenter.screenSize = geometry.size
        let orientationMask = PageFactory.getPageOrientationMask(page)
        self.deviceRotateHandler.updateOrientationMask(orientationMask)
        if orientationMask == .all {return}
        if AppDelegate.orientationLock != orientationMask {
            self.deviceRotateHandler.requestOrientationMask(orientationMask)
        }
        
    }
    
    private let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
    
   
}


