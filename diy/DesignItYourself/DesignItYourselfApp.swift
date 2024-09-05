//
//  DesignItYourselfApp.swift
//  DesignItYourself
//
//  Created by JeongCheol Kim on 5/20/24.
//

import SwiftUI
import CoreData
import UIKit
import Firebase

@main
struct DesignItYourselfApp: App {
    @UIApplicationDelegateAdaptor(DesignItYourselfAppDelegate.self) var appDelegate
    @StateObject var appPresenter = AppPresenter()
    let repo = Repository()

    var body: some Scene {
        WindowGroup {
            ScreenView()
                .environmentObject(repo)
                .environmentObject(KeyboardObserver())
                .environmentObject(repo.locationObserver)
                .environmentObject(repo.networkObserver)
                .environmentObject(repo.pagePresenter)
                .environmentObject(repo.dataProvider)
                .persistentSystemOverlays(self.appPresenter.persistentSystemOverlays)
                .modifier(MatchParent())
                .onAppear(){
                    
                }
                
        }
    }
}
class AppPresenter:ObservableObject{
    @Published var persistentSystemOverlays:Visibility = .visible
}
class DesignItYourselfAppDelegate: AppDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(false)
        #endif
        //GMSServices.provideAPIKey(GoogleApi.apiKey)
        //GMSPlacesClient.provideAPIKey(GoogleApi.apiKey)
        /*
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        */
        return true
    }
              
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        /*
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        */
        return true
    }
    
}
