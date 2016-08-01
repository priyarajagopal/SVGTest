//
//  WebViewController.swift
//  SVGTest
//
//  Created by Priya Rajagopal on 7/27/16.
//  Copyright © 2016 Invicara. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let localFile = NSBundle.mainBundle().pathForResource("Monkey", ofType: "svg")
        loadFileIntoWebView(localFile)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
}

extension WebViewController:WKNavigationDelegate {
    func loadFileIntoWebView(filePath:String? ) {
        let webView = WKWebView(frame: self.view.frame)
        webView.backgroundColor = UIColor.blueColor()
        if let filePath = filePath {
            webView.loadRequest(NSURLRequest(URL: NSURL(fileURLWithPath:filePath)))
            self.view.addSubview(webView)            
        }
        
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
            print("WebView finish navigation")
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
         print("Error with \(error)")
    }

}
