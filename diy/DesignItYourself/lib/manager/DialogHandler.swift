//
//  DialogHandler.swift
//  globe
//
//  Created by JeongCheol Kim on 10/3/23.
//

import Foundation
import UIKit
import SwiftUI
class DialogHandler{
    static func alert(
        title:String? = nil, message:String? = nil,
        preferredStyle:UIAlertController.Style = .alert,
        actions:[UIAlertAction] = [],
        cancel:(() -> Void)? = nil,
        confirm:(() -> Void)? = nil
    ){
        let alertController = UIAlertController (
            title: title,
            message: message,
            preferredStyle: preferredStyle)
        
        actions.forEach{ ac in
            alertController.addAction(ac)
        }
        
        if let cancel = cancel {
            let action = UIAlertAction(title: String.app.cancel, style: .default, handler: {_ in
                cancel()
            })
            alertController.addAction(action)
        }
        if let confirm = confirm{
            let action = UIAlertAction(title: String.app.confirm, style: .default, handler: {_ in
                confirm()
            })
            alertController.addAction(action)
        }
        let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
        window?.windows.first?.rootViewController?.present(alertController , animated: true, completion: nil)
        
    }
}
