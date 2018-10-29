//
//  AgreementViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/10/21.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD
import NotificationBannerSwift

class AgreementViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
    }
    
    private func setup() {
        
        webViewSetup()
        startingPage()
    }
    
    private func webViewSetup() {
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
    }
    
    private func startingPage() {
        
        SVProgressHUD.show()
        
        guard let url = URL(string: "https://termsfeed.com/eula/646a191f532da23e064a0d89869a550b") else {
            return
        }
        let request = URLRequest(url: url)
        
        webView.load(request)
        
    }
    
    @IBAction func goToEULAWeb(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        guard let url = URL(string: "https://termsfeed.com/eula/646a191f532da23e064a0d89869a550b") else {
            return
        }
        let request = URLRequest(url: url)
        
        webView.load(request)
        
    }
    
    @IBAction func goToPrivicyWeb(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        guard let url = URL(string: "https://privacypolicies.com/privacy/view/c82f8fb3e38aba20e4f0182e8c5a2fc4") else {
            return
        }
        let request = URLRequest(url: url)
        
        webView.load(request)
        
    }
    
    @IBAction func backToLoginPage(_ sender: UIButton) {
        
        dismiss(animated: true)
    }

}

extension AgreementViewController: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        BaseNotificationBanner.warningBanner(subtitle: "連線失敗，請確認網路連線狀況")
        
        SVProgressHUD.dismiss()
    }
    
}
