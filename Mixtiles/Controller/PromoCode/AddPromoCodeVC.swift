//
//  AddPromoCodeVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 04/09/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

protocol promocodeDiscountDelegate: class {
    func promocodeDicount(discount_type: String, discount: String, promoCode: String)
}

class AddPromoCodeVC: BaseViewController {

    //MARK:- Outlets
    @IBOutlet weak var txtPromoCode: UITextField!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblHeaderPromocode: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblPleaseAddPromoCode: UILabel!
    @IBOutlet weak var img_promocode: UIImageView!
    
    
    //MARK:- Variable Declerations
    weak var delegate : promocodeDiscountDelegate?
    var isShippingSet:((Bool)->())?
    
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocalization()
        setDefault()
    }
    
    
    //MARK:- Private Method
    func setDefault() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = formatter.string(from: Date())
        
        if defaults.value(forKey: "promocode") != nil {
            if let code = defaults.value(forKey: "promocode") as? String {
                self.txtPromoCode.text = code
            }
        }
        
        self.img_promocode.sd_setShowActivityIndicatorView(true)
        self.img_promocode.sd_setIndicatorStyle(.gray)
        self.img_promocode.sd_setImage(with: URL(string: "https://www.brickart.com.br/mobile_app/promo_code.png?date="+date), completed: nil)
        
        self.btnContinue.layer.cornerRadius = self.btnContinue.frame.height/2
    }
    
    func setLocalization() {
        self.lblHeaderPromocode.text = LocalizedLanguage(key: "lbl_title_promo_code", languageCode: lanCode)
        self.lblCode.text = LocalizedLanguage(key: "lbl_your_code", languageCode: lanCode)
        self.lblPleaseAddPromoCode.text = LocalizedLanguage(key: "lbl_please_add_code", languageCode: lanCode).uppercased()
        self.txtPromoCode.placeholder = LocalizedLanguage(key: "txt_promo_code", languageCode: lanCode)
        self.btnContinue.setTitle(LocalizedLanguage(key: "btn_continue", languageCode: lanCode), for: .normal)
    }
    
    func ApiPostCheckPromocode() {
        
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        
        let credentialData = "\(user):\(password)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        let base64Credentials = credentialData.base64EncodedString()
        
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        
        let Code = self.txtPromoCode.text!.trimmingCharacters(in: .whitespaces)
        let params : [String:Any] = ["promocode":"\(Code)"]
        
        Alamofire.request(MCheckPromocode, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { response in
//            debugPrint(response)
            if let json = response.result.value {
//                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if let status = dict.value(forKey: "status") as? Bool, status == true {
                    
                    if let data = dict.value(forKey: "data") as? NSDictionary {
                        
                        if let Type = data.value(forKey: "discount_type") as? String, let Discount = data.value(forKey: "discount") as? String {
                            self.delegate?.promocodeDicount(discount_type: Type, discount: Discount, promoCode: Code)
                            defaults.setValue(Code, forKey: "promocode")
                        }
                        self.navigationController?.popViewController(animated: true)
                        if self.isShippingSet != nil {
                            return self.isShippingSet!(true)
                        }
                    }
                }
                else {
                    self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                }
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
            }
            else {
                self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
            }
        }
    }
    
    //MARK:- Button Action
    @IBAction func Click_backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        if isShippingSet != nil {
            return isShippingSet!(true)
        }
    }
    
    @IBAction func Click_ContinueBtn(_ sender: UIButton) {
        
        if self.txtPromoCode.text!.isEmpty{
            showAlert(titleStr: LocalizedLanguage(key: "alert_promo_code", languageCode: lanCode), msg: "")
        }
        else{
            if Reachability.isConnectedToNetwork(){
                self.ApiPostCheckPromocode()
            }
            else{
                self.showAlert(titleStr: LocalizedLanguage(key: "alert_network", languageCode: lanCode), msg: "")
            }
        }
    }
    
    @IBAction func Click_helpBtn(_ sender: UIButton) {
        let helpvc = storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
        self.navigationController?.present(helpvc, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
