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
    @IBOutlet weak var lblHeaderOrder: UILabel!
    
    
    //MARK:- Variable Decleration
    var OrderRecipt: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults.removeObject(forKey: keyarymain)
        setLocalization()
        setDefault()
    }
    
    //MARK:- localization
    func setDefault() {
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        self.webview_OrderRecipt.loadRequest(URLRequest(url: URL(string: OrderRecipt)!))
        self.webview_OrderRecipt.scalesPageToFit = true
    }
    
    func setLocalization() {
        self.lblHeaderOrder.text = LocalizedLanguage(key: "lbl_title_order", languageCode: lanCode).uppercased()
    }
    
    //MARK:- WebView Method
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ApiUtillity.sharedInstance.dismissSVProgressHUD()
    }
    
    //MARK:- Button Action
    @IBAction func Click_backBtn(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func Click_SharBtn(_ sender: UIButton) {
        let AppURL = NSURL(string: OrderRecipt)
        
        let shareAll = [AppURL!] as [Any]
        
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
