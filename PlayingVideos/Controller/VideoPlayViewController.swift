//
//  VideoPlayViewController.swift
//  PlayingVideos
//
//  Created by colorsLion2 on 29/01/19.
//  Copyright © 2019 colorsLion2. All rights reserved.
//

import UIKit
import WebKit

class VideoPlayViewController: UIViewController , WKNavigationDelegate{

    var videourl = String()
    var videoWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var yPosition : CGFloat = 64
        
        if self.view.frame.size.height > 736 {
            yPosition = 88
        }
        
        if self.videourl.contains("https://www.youtube.com/embed") {
            if #available(iOS 11.0, *) {
                self.videoWebView = WKWebView(frame: CGRect(x: 8, y: (self.view.safeAreaLayoutGuide.layoutFrame.size.height / 2) - 100, width: self.view.frame.size.width - 16, height: 200))
            } else {
                self.videoWebView = WKWebView(frame: CGRect(x: 8, y: (self.view.frame.size.height / 2) - 100, width: self.view.frame.size.width - 16, height: 200))
            }
        } else {
            self.videoWebView = WKWebView(frame: CGRect(x: 0, y: yPosition, width: self.view.frame.size.width, height: self.view.frame.size.height - yPosition))
        }
        let urlRequest = URLRequest(url: URL(string: videourl)!)
        self.videoWebView.navigationDelegate = self
        self.view.addSubview(self.videoWebView)
        self.videoWebView.load(urlRequest)

        // Do any additional setup after loading the view.
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            print("start")
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       print("finish")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
