//
//  HelpVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 06/09/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit

class HelpVC: BaseViewController, UIWebViewDelegate {

    @IBOutlet weak var webview_FAQ: UIWebView!
    @IBOutlet weak var lblTitles: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var btnTalkToUs: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork() {
            ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
            self.webview_FAQ.loadRequest(URLRequest(url: URL(string: "http://www.brickart.com.br/mobile_app/FAQ/")!))
        }
        else {
            showAlert(titleStr: alertNetwork, msg: "")
        }
        self.setLocalization()
    }
    
    func setLocalization()
    {
        self.lblTitles.text = LocalizedLanguage(key: "lbl_help", languageCode: lanCode)
        self.lblDetails.text = LocalizedLanguage(key: "lbl_helpdetail", languageCode: lanCode)
        self.btnTalkToUs.setTitle(LocalizedLanguage(key: "btn_talk_to_us", languageCode: lanCode), for: .normal)
    }
    
    //MARK:- WebView Method
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ApiUtillity.sharedInstance.dismissSVProgressHUD()
    }

    @IBAction func Click_CloseBtn(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func Click_talkToUS(_ sender: UIButton) {
        Freshchat.sharedInstance().showConversations(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
