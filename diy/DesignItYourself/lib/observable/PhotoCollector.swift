//
//  PhotoCollector.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/27.
//

import Foundation
import SwiftUI
import PhotosUI
import CoreTransferable
import Combine

enum PhotoCollectorEvent{
    case updateAuthorization(PHAuthorizationStatus)
    case completed([PhotoModel])
}


@MainActor
class PhotoModel: ObservableObject, PageProtocol {
    private var fixedWidth:CGFloat? = nil
    init(fixedWidth:CGFloat? = nil){
        self.fixedWidth = fixedWidth
    }
    
    enum ImageState {
        case empty
        case loading(Progress)
        case success(Image, png:Data?)
        case failure(Error)
    }
    enum TransferError: Error {
        case importFailed
    }
    private(set) var asset: PHAsset? = nil
    @Published private(set) var imageState: ImageState = .empty
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                let id = imageSelection.itemIdentifier ?? ""
                let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
                self.asset = assetResults.firstObject
               
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    struct PhotoImage: Transferable {
        let image: Image
        let data: Data?
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
                
                
            #if canImport(AppKit)
                guard let nsImage = NSImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(nsImage: nsImage)
                return PhotoImage(image: image)
            #elseif canImport(UIKit)
                guard let uiImage = UIImage(data: data)?.normalized().resizeMaintainAspectRatio(width: 320) else {
                    throw TransferError.importFailed
                }
                
                let image = Image(uiImage: uiImage)
                return PhotoImage(image: image, data: uiImage.pngData())
            #else
                throw TransferError.importFailed
            #endif
            }
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: PhotoImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    DataLog.d("Failed to get the selected item.", tag: self.tag)
                    return
                }
                switch result {
                case .success(let photo?):
                    self.imageState = .success(photo.image, png: photo.data)
                case .success(nil):
                    self.imageState = .failure(TransferError.importFailed)
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
}

@MainActor
class PhotoCollector : ObservableObject , PageProtocol{
    private(set) var total:Int = 0
    @Published private(set) var progress:Float = 0
    @Published private(set) var event:PhotoCollectorEvent? = nil
        {didSet{ if event != nil { event = nil} }}
    
    private var anyCancellable = Set<AnyCancellable>()
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            if imageSelections.isEmpty {return}
            self.clear()
            let max = imageSelections.count
            self.total = max
            var count = 0
            var collect:[PhotoModel] = []
            func com(_ md:PhotoModel){
                collect.append(md)
                count += 1
                self.progress = Float(count) / Float(max)
                if count == max {
                    self.completed(collect: collect)
                }
            }
            
            imageSelections.forEach{selection in
                let md = PhotoModel()
                md.$imageState.sink( receiveValue: { state in
                    switch state {
                    case .loading, .empty : break
                    default : 
                        DispatchQueue.main.async {
                            com(md)
                        }
                        
                    }
                }).store(in: &anyCancellable)
                DispatchQueue.main.async {
                    md.imageSelection = selection
                }
            }
            imageSelections = []
        }
    }
    private func clear(){
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
    }
    
    private func completed(collect:[PhotoModel]){
        self.clear()
        self.event = .completed(collect)
    }
    
    @discardableResult
    func photoLibraryAvailabilityCheck() -> PHAuthorizationStatus
    {
        let status = PHPhotoLibrary.authorizationStatus()
        if status != PHAuthorizationStatus.authorized
        {
            PHPhotoLibrary.requestAuthorization( self.requestAuthorizationHandler )
        }
        return status
    }
    private func requestAuthorizationHandler(status: PHAuthorizationStatus)
    {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized
        {
            self.alertToEncouragePhotoLibraryAccess()
        }
        self.event = .updateAuthorization(status)
    }
    func alertToEncouragePhotoLibraryAccess()
    {
        let cameraUnavailableAlertController = UIAlertController (
            title: "String.alert.requestAccessPhoto",
            message: "String.alert.requestAccessPhotoText",
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
                let status = PHPhotoLibrary.authorizationStatus()
                self.event = .updateAuthorization(status)
            })
        }
        
    }
}
