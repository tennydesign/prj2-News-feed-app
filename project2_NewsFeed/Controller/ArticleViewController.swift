//
//  ArticleViewController.swift
//  project2_NewsFeed
//
//  Created by Tennyson Pinheiro on 10/15/17.
//  Copyright © 2017 Tenny. All rights reserved.
//

import UIKit
import WebKit

class ArticleViewController: UIViewController, WKNavigationDelegate {
    
    
    
    @IBOutlet weak var webViewKit: WKWebView!
    @IBOutlet weak var hitBackToArticles: UIBarButtonItem!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    
    var receivedURL: String?
    var receivedFromCell: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webViewKit.navigationDelegate = self
        
        loading.startAnimating()
        let requestURL = receivedURL ?? "Not received"
        
        if !(requestURL == "Not received") {
            let requestURL = URL(string: receivedURL!)
            webViewKit.load(URLRequest(url: requestURL!))
        }
        

    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        let when = DispatchTime.now() + 2.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.loading.stopAnimating()
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func hitBackToArticles(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func hitBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
