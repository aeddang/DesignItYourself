//
//  ComponentWebView.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
import Combine


struct CPWebView: PageView {
    @ObservedObject var viewModel:WebViewModel = WebViewModel()
    var config: WKWebViewConfiguration? = nil
    
    var body: some View {
        ZStack{
            CustomWebView( viewModel: self.viewModel, config: self.config )
            if self.isLoading {
                CircularSpinner()
            }
        }
        .onReceive(self.viewModel.$isLoading) { isLoading in
            withAnimation {
                self.isLoading = isLoading
            }
        }
        /*
        .onReceive(self.pageObservable.$status){ stat in
            if stat == .disconnect || stat == .disAppear { self.viewModel.status = .end }
        }
         */
    }
    @State private var isLoading:Bool = false
}

struct CustomWebView : UIViewRepresentable, WebViewProtocol, PageProtocol {
     @ObservedObject var viewModel:WebViewModel
    var config: WKWebViewConfiguration? = nil
    var path: String = ""
    var request: URLRequest? {
        get{
            ComponentLog.log("origin request " + viewModel.path , tag:self.tag )
            ComponentLog.log("encoded not use" , tag:self.tag )
            guard let url:URL = URL(string: viewModel.path) else { return nil }
            return URLRequest(url: url)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        let uiView = creatWebView(config: self.config)
        uiView.navigationDelegate = context.coordinator
        uiView.uiDelegate = context.coordinator
        uiView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
       
        return uiView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if self.viewModel.status != .update { return }
        guard let e = self.viewModel.request else {return}
        switch e {
        case .evaluateJavaScript(let jsStr):
            ComponentLog.d("call -> " + jsStr, tag: "callJS")
            break
        default : break
            
        }
        DispatchQueue.main.async {
            if uiView.isLoading {
                self.viewModel.status = .error
                self.viewModel.error = .busy
                return
            }
            update(uiView , evt:e)
        }
    }
    
    private func checkLoading(_ uiView: WKWebView){
        var job:AnyCancellable? = nil
        job = Timer.publish(every: 0.1, on:.current, in: .common)
            .autoconnect()
            .sink{_ in
                if self.viewModel.status == .end {
                    job?.cancel()
                    return
                }
                if !self.viewModel.isLoading {
                    job?.cancel()
                    self.viewModel.status = .complete
                    return
                }
        }
    }
    
    private func goHome(_ uiView: WKWebView){
        self.viewModel.path = self.viewModel.base
        if self.viewModel.path == "" {
            self.viewModel.error = .update(.home)
            return
        }
        self.viewModel.status = .ready
        self.viewModel.isLoading = true
        load(uiView)
        checkLoading(uiView)
    }
    
    fileprivate func callJS(_ uiView: WKWebView, jsStr: String) {
        ComponentLog.d(jsStr, tag: "callJS")
        uiView.evaluateJavaScript(jsStr, completionHandler: { (result, error) in
            let resultString = result.debugDescription
            let errorString = error.debugDescription
            let msg = "result: " + resultString + " error: " + errorString
            ComponentLog.d(msg, tag: "callJS")
        })
    }
    
    private func update(_ uiView: WKWebView, evt:WebViewRequest){
        switch evt {
        case .home:
            goHome(uiView)
            return
        case .writeHtml(let html):
            uiView.loadHTMLString(html, baseURL: nil)
            return
        case .evaluateJavaScript(let jsStr):
            self.callJS(uiView, jsStr: jsStr)
            return
        case .evaluateJavaScriptMethod(let fn, let dic):
            var jsStr = ""
            if let dic = dic {
                let jsonString = AppUtil.getJsonString(dic: dic) ?? ""
                jsStr = fn + "(\'" + jsonString + "\')"
            } else {
                jsStr = fn + "()"
            }
            self.callJS(uiView, jsStr: jsStr)
            return
        case .back:
            if uiView.canGoBack {uiView.goBack()}
            else {
                self.viewModel.error = .update(.back)
                return
            }
        case .foward:
            
            if uiView.canGoForward {uiView.goForward() }
            else {
                self.viewModel.error = .update(.foward)
                return
            }
        case .reload:
            uiView.reload()
            
        case .link(let path) :
            viewModel.path = path
            viewModel.isLoading = true
            load(uiView)
            uiView.becomeFirstResponder()
        }
        self.viewModel.status = .ready
        self.viewModel.request = nil
        checkLoading(uiView)
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) {
        dismantleUIView( uiView )
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, PageProtocol {
        var parent: CustomWebView
        init(_ parent: CustomWebView) {
            self.parent = parent
        }
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     preferences: WKWebpagePreferences,
                     decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            let path = navigationAction.request.url?.absoluteString ?? ""
            if path.hasPrefix("vnd.youtube:") {
                AppUtil.openURL(path)
                decisionHandler(.cancel, preferences)
                return
            }
            decisionHandler(.allow, preferences)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {}
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//            self.parent.viewModel.isLoading = true
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {}
        
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            self.parent.viewModel.status = .complete
            self.parent.viewModel.isLoading = false
        }
        
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            ComponentLog.d("error: " + error.localizedDescription , tag: self.tag )
    
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            
            //self.parent.appSceneObserver.alert = .alert(nil,  message, nil, completionHandler)
           
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            
            //self.parent.appSceneObserver.alert = .confirm(nil,  message, completionHandler)
        }

        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
                     defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (String?) -> Void) {
            
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                     decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
            
            guard
                let response = navigationResponse.response as? HTTPURLResponse,
                let url = navigationResponse.response.url
                else {
                    decisionHandler(.cancel)
                    return
                }
            
            
            
            if let headerFields = response.allHeaderFields as? [String: String] {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
                cookies.forEach { (cookie) in
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
            decisionHandler(.allow)
        }
    }
}

#if DEBUG
struct CPWebView_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CPWebView(viewModel:WebViewModel(base: "https://www.todaypp.com")).contentBody
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

