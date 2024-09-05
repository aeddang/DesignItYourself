//
//  AppleButton.swift
//  Valla
//
//  Created by KimJeongCheol on 2020/12/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct AppleButton: UIViewRepresentable{

    func makeUIView(context: UIViewRepresentableContext<AppleButton>) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton()
        return button
    }

    func updateUIView(_ uiView:ASAuthorizationAppleIDButton, context: UIViewRepresentableContext<AppleButton>) {}
}
