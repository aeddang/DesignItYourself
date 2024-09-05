//
//  GoogleSignManager.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/07/08.
//
/*
import Foundation
import GoogleSignIn

class GoogleSignManager:ObservableObject, PageProtocol, Sns{
    
    //static let clientId = "com.googleusercontent.apps.474132217178-gs267ilhklucpvv8dlt5usphb8atplf2"
    static let clientId = "474132217178-gs267ilhklucpvv8dlt5usphb8atplf2.apps.googleusercontent.com"
    static let signInConfig:GIDConfiguration = GIDConfiguration(clientID: clientId)
    
    @Published var respond:SnsResponds? = nil
    @Published var error:SnsError? = nil
    let type = SnsType.google
  
 
    func getAccessTokenInfo(){
        guard let token = GIDSignIn.sharedInstance.currentUser?.authentication.accessToken else {
            self.respond = SnsResponds(event: .invalidToken, type: type)
            return
        }
        if let exfire = GIDSignIn.sharedInstance.currentUser?.authentication.accessTokenExpirationDate {
            if exfire.timeIntervalSinceNow <= 0 {
                self.respond = SnsResponds(event: .invalidToken, type: type)
            }
        }
        self.respond = SnsResponds(event: .getToken, type: type, data:token)
    }
    
    func getUserInfo(){
        
    }
    
    
    func requestLogin() {
        guard  let vc = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController else { return }
        GIDSignIn.sharedInstance.signIn(with: Self.signInConfig, presenting: vc){ user, error in
            if let error = error as? NSError {
                if error.code == -5 {return}
                self.error = SnsError(event: .login, type: self.type, error: error)
                return
            }
            guard let user = user else { return }
            let snsUser = SnsUser(
                snsType: self.type,
                snsID: user.userID ?? "",
                snsToken: user.authentication.accessToken
            )
            self.respond = SnsResponds(event: .login, type: self.type, data:snsUser)
            
            let emailAddress = user.profile?.email
            let fullName = user.profile?.name
            //let givenName = user.profile?.givenName
            //let familyName = user.profile?.familyName
            let profilePicUrl = user.profile?.imageURL(withDimension: 320)
            
            let userInfo = SnsUserInfo(
                nickName: fullName,
                profile: profilePicUrl?.absoluteString,
                email: emailAddress
            )
            self.respond = SnsResponds(event: .getProfile, type: self.type, data:userInfo)
            
        }
    }
    
    func requestLogOut() {
        GIDSignIn.sharedInstance.signOut()
        self.respond = SnsResponds(event: .logout, type: type)
    }
    
    func requestUnlink() {
        DataLog.e("Not supported", tag: self.tag)
    }
    
    
}
*/
