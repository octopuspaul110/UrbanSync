//
//  PaystackWebView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 12/04/2026.
//

import SwiftUI
import WebKit

struct PaystackWebView: UIViewRepresentable {
    let urlString  : String
    let onComplete : () -> Void
    @Binding var isLoading : Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, onComplete : onComplete)
    }
    
    func makeUIView(context : Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        if let url = URL(string : urlString) {
            webView.load(URLRequest(url : url))
        }
        return webView
    }
    func updateUIView(_ uiView : WKWebView,context : Context){}
    class Coordinator : NSObject, WKNavigationDelegate {
        let onComplete : () -> Void
        var parent     : PaystackWebView
        
        init(parent: PaystackWebView, onComplete: @escaping () -> Void) {
            self.onComplete = onComplete
            self.parent     = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            // optionally call a failure callback here
        }
        
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy
        ) -> Void) {
            if let url = navigationAction.request.url?.absoluteString,
               url.contains("/payment/callback") {
                onComplete()
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}
