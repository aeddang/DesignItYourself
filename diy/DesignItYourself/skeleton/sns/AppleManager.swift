//
//  AppleManager.swift
//  Valla
//
//  Created by KimJeongCheol on 2020/12/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import AuthenticationServices

class AppleManager:NSObject,
                   ObservableObject,
                   ASAuthorizationControllerDelegate,
                   ASAuthorizationControllerPresentationContextProviding,
                   PageProtocol,Sns{ 
    
    
    
    @Published var respond:SnsResponds? = nil
    @Published var error:SnsError? = nil
    let type = SnsType.apple

    func requestLogin(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func requestLogOut(){
        KeychainItem.deleteUserIdentifierFromKeychain() 
        self.respond = SnsResponds(event: .logout, type: self.type)
    }
    

    func getAccessTokenInfo(){
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                            ASAuthorizationPasswordProvider().createRequest()]
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let w = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.view.window
        return w!
    }
                    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        self.error = SnsError(event: .login, type: self.type, error: error)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email ?? ""
            let token = appleIDCredential.authorizationCode?.base64EncodedString() ?? ""
            self.saveUserInKeychain(userIdentifier)
            DataLog.d("userIdentifier " + userIdentifier , tag: self.tag)
            DataLog.d("fullName " + fullName.debugDescription , tag: self.tag)
            DataLog.d("email " + email  , tag: self.tag)
            DataLog.d("token " + token  , tag: self.tag)
            
            let user = SnsUser(
                snsType: self.type, snsID: userIdentifier, snsToken: token
            )
            self.respond = SnsResponds(event: .login, type: self.type, data:user)
            
            let userInfo = SnsUserInfo(
                nickName: fullName?.nickname ,
                profile: nil,
                email: email
            )
            self.respond = SnsResponds(event: .getProfile, type: self.type, data:userInfo)
        
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            DataLog.d("passwordCredential " + username + " " + password , tag: self.tag)
        default:
            break
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
            if let err = error {
                DataLog.e("getToken error " + err.localizedDescription, tag: self.tag)
                self.error = SnsError(event: .getToken, type: self.type, error: err)
                return
            }
            
            switch credentialState {
            case .authorized:
                self.respond = SnsResponds(event: .getToken, type: self.type)
                break // The Apple ID credential is valid.
            case .revoked, .notFound:
                self.respond = SnsResponds(event: .invalidToken, type: self.type)
                break
            default:
                break
            }
        }
        return true
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: KeychainItem.SERVICE_ID, account: KeychainItem.USER_IDENTIFIER).saveItem(userIdentifier)
        } catch {
            DataLog.e("Unable to save userIdentifier to keychain.", tag: self.tag)
        
        }
    }
    
    func getUserInfo() {
        DataLog.e("use requestLogin", tag: self.tag)
    }
    
    func requestUnlink() {
        DataLog.e("Not supported", tag: self.tag)
    }
}
