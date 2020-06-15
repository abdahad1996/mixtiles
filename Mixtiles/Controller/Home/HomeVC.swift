//
//  HomeVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 06/09/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import Alamofire
import WebKit

class HomeVC: BaseViewController,UIGestureRecognizerDelegate, UIWebViewDelegate,WKNavigationDelegate {

    @IBOutlet weak var sliderWebkit: WKWebView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblUnreadMsg: UILabel!
    @IBOutlet weak var webview_AboutUs: UIWebView!
    @IBOutlet weak var btnCreateSet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderWebkit.navigationDelegate = self
        //sliderWebkit.layer.cornerRadius = 8
        sliderWebkit.clipsToBounds = true
        
        if Reachability.isConnectedToNetwork() {
            ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let date = formatter.string(from: Date())
           /* self.webview_AboutUs.loadRequest(URLRequest(url: URL(string: "https://www.brickart.com.br/mobile_app/?date="+date)!))*/
            let url = URL(string: "https://www.brickart.com.br/mobile_app/?date="+date)!
            sliderWebkit.load(URLRequest(url: url))
            sliderWebkit.allowsBackForwardNavigationGestures = true
            self.getPrice()
            self.getShipping()
        }
        else {
            showAlert(titleStr: LocalizedLanguage(key: "alert_network", languageCode: lanCode), msg: "")
        }
        
        self.setLocalization()
    }
    
    func setLocalization()
    {
        self.lblTitle.text = LocalizedLanguage(key: "lbl_home_title", languageCode: lanCode).uppercased()
        self.btnCreateSet.setTitle(LocalizedLanguage(key: "btn_createaset", languageCode: lanCode), for: .normal)
    }
    
    //MARK:- WebView Method
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ApiUtillity.sharedInstance.dismissSVProgressHUD()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //Activity.stopAnimating()
        ApiUtillity.sharedInstance.dismissSVProgressHUD()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
       //Activity.stopAnimating()
        ApiUtillity.sharedInstance.dismissSVProgressHUD()
    }
    
    //MARK:- API_shipping
    func getShipping() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = formatter.string(from: Date())
        
        Alamofire.request("https://www.brickart.com.br/mobile_app/shipping.txt?date="+date, method: .get, parameters: nil, encoding: JSONEncoding.default).responseString { response in
//            debugPrint(response)
            if let dict = response.result.value {
                
                let test = String(dict.filter { !" \n\r".contains($0) }).replacingOccurrences(of: "\'", with: "\"")
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
            else {
                return
            }
        }
    }
    
    //MARK:- API_price
    func getPrice() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = formatter.string(from: Date())
        
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request("https://www.brickart.com.br/mobile_app/price.txt?date="+date, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
//            debugPrint(response)
            
            if let json = response.result.value {
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if let PriceDic = dict["data"] as? NSDictionary {
                    defaults.set(PriceDic, forKey: "price")
                }
                
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
            }
            else {
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
            }
        }
    }
    
    //MARK:- Button Action
    @IBAction func Click_helpBtn(_ sender: UIButton) {
        let helpvc = storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
        self.navigationController?.present(helpvc, animated: false, completion: nil)
    }

    @IBAction func Click_CreateASetBtn(_ sender: UIButton) {
        //
        let ImageSelectVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(ImageSelectVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970)
    }
}
