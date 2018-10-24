//
//  AddPromoCodeVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 04/09/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import Alamofire

protocol promocodeDiscountDelegate: class {
    func promocodeDicount(dict: NSDictionary, promoCode: String)
}

class AddPromoCodeVC: BaseViewController {

    @IBOutlet weak var txtPromoCode: UITextField!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnNoOtherTime: UIButton!
    @IBOutlet weak var lblHeaderPromocode: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblPleaseAddPromoCode: UILabel!
    
    weak var delegate : promocodeDiscountDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btnContinue.layer.cornerRadius = self.btnContinue.frame.height/2
        
        self.setLocalization()
    }

    func setLocalization()
    {
        self.lblHeaderPromocode.text = LocalizedLanguage(key: "lbl_title_promo_code", languageCode: lanCode)
        self.lblCode.text = LocalizedLanguage(key: "lbl_your_code", languageCode: lanCode)
        self.lblPleaseAddPromoCode.text = LocalizedLanguage(key: "lbl_please_add_code", languageCode: lanCode)
        self.txtPromoCode.placeholder = LocalizedLanguage(key: "txt_promo_code", languageCode: lanCode)
        self.btnContinue.setTitle(LocalizedLanguage(key: "btn_continue", languageCode: lanCode), for: .normal)
        self.btnNoOtherTime.setTitle(LocalizedLanguage(key: "btn_no_other_time", languageCode: lanCode), for: .normal)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Click_backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Click_ContinueBtn(_ sender: UIButton) {
        
        if self.txtPromoCode.text!.isEmpty{
            showAlert(titleStr: "Enter promo code", msg: "")
        }else{
            if Reachability.isConnectedToNetwork(){
                self.ApiPostCheckPromocode()
            }else{
                showAlert(titleStr: alertNetwork, msg: "")
            }
        }
    }
    
    func ApiPostCheckPromocode()
    {
        self.showHUD()
        let credentialData = "\(user):\(password)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        let base64Credentials = credentialData.base64EncodedString()
        
        let headers = [
            "Authorization": "Basic \(base64Credentials)",
            "Content-Type": "application/json"]

        let finalStr = self.txtPromoCode.text!.trimmingCharacters(in: .whitespaces)
        let param : [String:Any] = ["promocode":"\(finalStr)"]
        
        Alamofire.request(MCheckPromocode, method: .post, parameters: param, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            
            self.hideHUD()
            if response.error != nil{
                self.showAlert(titleStr: alertMissing, msg: "")
                return
            }
            
            if response.result.value != nil{
                let ResponseDict = response.result.value as! NSDictionary
                if let status = ResponseDict.value(forKey: "status") as? Bool{
                    if status == true{
                        if let data = ResponseDict.value(forKey: "data") as? NSDictionary{
                            self.delegate?.promocodeDicount(dict: data, promoCode: finalStr)
                            print(data)
                            UserDefaults.standard.set((data.value(forKey: "discounted_percentage") as? String) ?? "", forKey: "DISCOUNT")
                            UserDefaults.standard.synchronize()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else{
                       self.showAlert(titleStr: alertMissing, msg: "")
                    }
                }
                print(ResponseDict)
            }
        }
    }
    
    @IBAction func Click_NoOtherTimeBtn(_ sender: UIButton) {
        
    }

}
