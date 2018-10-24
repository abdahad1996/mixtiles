//
//  BoletoOrderCompletVC.swift
//  Mixtiles
//
//  Created by Viprak-Sumit on 12/10/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit

class BoletoOrderCompletVC: UIViewController, UIWebViewDelegate {

    //MARK:- Outlets
    @IBOutlet weak var webview_OrderRecipt: UIWebView!
    
    //MARK:- Variable Decleration
    var OrderRecipt: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        self.webview_OrderRecipt.loadRequest(URLRequest(url: URL(string: OrderRecipt)!))
        self.webview_OrderRecipt.scalesPageToFit = true
    }
    
    //MARK:- WebView Method
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ApiUtillity.sharedInstance.dismissSVProgressHUD()
    }
    
    @IBAction func Click_backBtn(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
