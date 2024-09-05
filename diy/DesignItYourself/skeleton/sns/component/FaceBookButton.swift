//
//  FaceBookButton.swift
//  Valla
//
//  Created by KimJeongCheol on 2020/12/03.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
/*
import Foundation
import SwiftUI
import FBSDKLoginKit
import FacebookLogin
struct FaceBookButton: UIViewRepresentable{
    @EnvironmentObject var snsManager:SnsManager
    class Coordinator: NSObject, LoginButtonDelegate, PageProtocol {
        var parent: FaceBookButton
        init(_ parent: FaceBookButton) {
            self.parent = parent
        }
        func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
            DataLog.d("Logout", tag: self.tag)
            
            self.parent.snsManager.fb.onLogOut() 
        }
        func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
            if let e = error {
                DataLog.d("Login error. " + e.localizedDescription, tag: self.tag)
                self.parent.snsManager.fb.onLoginError(error: e)
                return
            }
            guard let result = result else { return }
            DataLog.d("Login", tag: self.tag)
            guard let token = result.token else { return }
            self.parent.snsManager.fb.onLogin(token:token)
        }
    }

    func makeCoordinator() -> FaceBookButton.Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<FaceBookButton>) -> FBLoginButton {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        button.delegate = context.coordinator
        return button
    }

    func updateUIView(_ uiView:FBLoginButton, context: UIViewRepresentableContext<FaceBookButton>) {}
}
*/
