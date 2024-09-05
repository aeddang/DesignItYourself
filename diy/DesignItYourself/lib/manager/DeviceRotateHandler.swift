//
//  DeviceRotateHandler.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/21.
//
import SwiftUI
import Foundation

open class AppDelegate: NSObject, UIApplicationDelegate {

    static var orientationLock = UIInterfaceOrientationMask.all
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

class DeviceRotateHandler{
    private var currentOrientationMask:UIInterfaceOrientationMask = .all
    private let delayCurrentDeviceOrientation:ScheduleExcutor = ScheduleExcutor()
    func updateOrientationMask(_ orientationMask:UIInterfaceOrientationMask){
        self.delayCurrentDeviceOrientation.cancel()
        self.currentOrientationMask = orientationMask
        AppDelegate.orientationLock = orientationMask
    }
    
    func requestOrientationMask(_ orientationMask:UIInterfaceOrientationMask){
        self.delayCurrentDeviceOrientation.cancel()
        AppDelegate.orientationLock = orientationMask
        self.rotateDevice(orientationMask)
        DispatchQueue.main.async{
            self.attemptRotationToDeviceOrientation()
        }
        self.delayCurrentDeviceOrientation.reservation(delay: 1.0){
            AppDelegate.orientationLock = self.currentOrientationMask
        }
    }
    
    private func attemptRotationToDeviceOrientation(){
        if #available(iOS 16.0, *) {
            UINavigationController().setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }
    
    private func rotateDevice(_ orientationMask:UIInterfaceOrientationMask){
        if #available(iOS 16.0, *) {
            let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
            window?.requestGeometryUpdate(.iOS(interfaceOrientations: orientationMask))
        } else {
            let mask = AppUtil.switchDeviceMaskToOrientation(orientationMask)
            UIDevice.current.setValue(mask.rawValue, forKey: "orientation")
        }
    }
    
    
}
