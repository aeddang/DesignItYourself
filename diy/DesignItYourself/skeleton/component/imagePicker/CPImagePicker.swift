//
//  CustomCamera.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/22.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Photos

struct CPImagePicker : PageView {
    @ObservedObject var viewModel:ImagePickerModel = ImagePickerModel()
    var isModal:Bool = false
    var sourceType:UIImagePickerController.SourceType = .camera
    var cameraDevice:UIImagePickerController.CameraDevice = .rear
    var body: some View {
        VStack(spacing: 0){
            if self.isGranted {
                CustomImagePicker(
                    viewModel:viewModel,
                    sourceType: sourceType,
                    cameraDevice: cameraDevice)
            } else {
                if self.isModal {
                    HStack(spacing: 0){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        ImageButton(defaultImage: Asset.component.button.close){ _ in
                            self.viewModel.event = .cancel
                        }
                    }
                    .padding(.all, Dimen.margin.regular)
                }
                ZStack{
                    if self.isModal {
                        TextButton(defaultText: String.alert.requestAccessCameraText){ _ in
                            AppUtil.goAppSettings()
                        }
                        
                    } else {
                        TextButton(defaultText: String.alert.requestAccessCamera){ _ in
                            self.alertToEncourageCameraAccess()
                        }
                    }
                }
                .modifier(MatchParent())
            }
        }
        .modifier(MatchParent())
        .background(Color.app.black)
        .onAppear{
            self.cameraAvailabilityCheck()
        }
    }
    
    
    
    @State var isGranted:Bool = true
    private func cameraAvailabilityCheck(){
        AVCaptureDevice.requestAccess(for: .video){ isGranted in
           DispatchQueue.main.async {
                self.isGranted = isGranted
           }
        }
    }
    
    
    func alertToEncourageCameraAccess()
    {
        let cameraUnavailableAlertController = UIAlertController (
            title: String.alert.requestAccessCamera,
            message: String.alert.requestAccessCameraText,
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: String.app.setting, style: .destructive) { (_) -> Void in
            AppUtil.goAppSettings()
        }
        let cancelAction = UIAlertAction(title: String.app.confirm, style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(settingsAction)
        cameraUnavailableAlertController .addAction(cancelAction)
        let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
        DispatchQueue.main.async {
            window?.windows.first?.rootViewController?.present(cameraUnavailableAlertController , animated: true, completion: {
                self.cameraAvailabilityCheck()
                
            })
        }
    }
}


#if DEBUG
struct CPImagePicker_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CPImagePicker()
            .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif

