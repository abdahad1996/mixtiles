//
//  HomeVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 06/09/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import Alamofire

class HomeVC: BaseViewController,UIGestureRecognizerDelegate, UIWebViewDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblUnreadMsg: UILabel!
    @IBOutlet weak var webview_AboutUs: UIWebView!
    @IBOutlet weak var btnCreateSet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork() {
            ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
            self.webview_AboutUs.loadRequest(URLRequest(url: URL(string: "http://www.brickart.com.br/mobile_app/")!))
            
            self.getPrice()
            self.getShipping()
        }
        else {
            showAlert(titleStr: alertNetwork, msg: "")
        }
        self.setLocalization()
    }
    
    func setLocalization()
    {
        self.lblTitle.text = LocalizedLanguage(key: "lbl_home_title", languageCode: lanCode)
        self.btnCreateSet.setTitle(LocalizedLanguage(key: "btn_createaset", languageCode: lanCode), for: .normal)
    }
    
    //MARK:- WebView Method
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ApiUtillity.sharedInstance.dismissSVProgressHUD()
    }
    
    //MARK:- API_shipping
    func getShipping() {
        
        Alamofire.request("http://www.brickart.com.br/mobile_app/shipping.txt", method: .post, parameters: nil, encoding: JSONEncoding.default).responseString { response in
            if response.error != nil {
                print(response.error.debugDescription)
                return
            }
            
            if response.result.value != nil {
                print(response.result.value as Any)
                
                let test = String(response.result.value!.filter { !" \n\r".contains($0) }).replacingOccurrences(of: "\'", with: "\"")
                print(test)
    
                let data = test.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                    
                    if let shippingDic = json["data"] as? NSDictionary {
                        defaults.set(shippingDic, forKey: "shipping")
                        defaults.synchronize()
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
    }
    
    //MARK:- API_price
    func getPrice() {
        
        Alamofire.request("http://www.brickart.com.br/mobile_app/price.txt", method: .get, parameters: nil, encoding: JSONEncoding.default).responseString { response in
            if response.error != nil {
                print(response.error.debugDescription)
                return
            }
            
            if response.result.value != nil {
                print(response.result.value as Any)
                
                let test = String(response.result.value!.filter { !" \n\r".contains($0) }).replacingOccurrences(of: "\'", with: "\"")
                print(test)
                
                let data = test.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                    
                    if let shippingDic = json["data"] as? NSDictionary {
                        defaults.set(shippingDic, forKey: "price")
                        defaults.synchronize()
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
    }
    
    //MARK:- Button Action
    @IBAction func Click_helpBtn(_ sender: UIButton) {
        if self.lblUnreadMsg.isHidden == true{
            let helpvc = storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
            self.navigationController?.present(helpvc, animated: false, completion: nil)
        }
        else{
            Freshchat.sharedInstance().showConversations(self)
        }
    }

    @IBAction func Click_CreateASetBtn(_ sender: UIButton) {
        
        defaults.removeObject(forKey: keydictAddress)
        defaults.removeObject(forKey: keydictcreditcard)
        defaults.removeObject(forKey: keyTokenCreditCard)
        defaults.removeObject(forKey: keyPaymentMethod)
        defaults.removeObject(forKey: keycpfno)
        defaults.removeObject(forKey: keyCardIndex)
        
        let ImageSelectVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(ImageSelectVC, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
