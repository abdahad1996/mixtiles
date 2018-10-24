//
//  OrderCompleteVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 04/09/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import Alamofire

class OrderCompleteVC: BaseViewController {

    @IBOutlet weak var vwOrderDetails: UIView!
    @IBOutlet weak var lblHeaderOrder: UILabel!
    @IBOutlet weak var lblThankyou: UILabel!
    @IBOutlet weak var lblOrderConfirmed: UILabel!
    @IBOutlet weak var lblPaymentNo: UILabel!
    @IBOutlet weak var lblOrderNo: UILabel!
    @IBOutlet weak var lblTitlePaymentId: UILabel!
    @IBOutlet weak var lblTitleOrderId: UILabel!
    @IBOutlet weak var lblTitlesFinalAmt: UILabel!
    @IBOutlet weak var lblTitlePaymentMethod: UILabel!
    
    @IBOutlet weak var btnTapeHere: UIButton!
    @IBOutlet weak var lblTitlesEmail: UILabel!
    @IBOutlet weak var lblOrderAmt: UILabel!
    @IBOutlet weak var lblPaymentMethod: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var view_BoletoRecipt: UIView!
    
    var DictResponse : NSMutableDictionary!
    var id = NSNumber()
    var paymentMethod = String()
    
    var email : String!
    var orderid : String!
    var orderamt : String!
    var transactionid : NSNumber!
    var cardnumber: String!
    var cardtype : String!
    var cardexpiry : String!
    var firstname : String!
    var lastname : String!
//    var discountamt : String!
    var BoletoOrderRecipt: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.vwOrderDetails.ShadowWithOpacity()
        print(DictResponse)
        
        self.setLocalization()
        SetUI()
        ApiPostSavePayment()
        
        
    }
    
    func setLocalization()
    {
        self.lblHeaderOrder.text = LocalizedLanguage(key: "lbl_title_order", languageCode: lanCode)
        self.lblThankyou.text = LocalizedLanguage(key: "lbl_thank_you", languageCode: lanCode)
        self.lblOrderConfirmed.text = LocalizedLanguage(key: "lbl_your_order_confirmed", languageCode: lanCode)
        self.lblTitlePaymentId.text = LocalizedLanguage(key: "lbl_your_payment_id", languageCode: lanCode)
        self.lblTitleOrderId.text = LocalizedLanguage(key: "lbl_order_id", languageCode: lanCode)
        self.lblTitlesFinalAmt.text = LocalizedLanguage(key: "lbl_final_amt", languageCode: lanCode)
        self.lblTitlePaymentMethod.text = LocalizedLanguage(key: "lbl_payment_method", languageCode: lanCode)
        self.lblTitlesEmail.text = LocalizedLanguage(key: "txt_email", languageCode: lanCode)
        self.btnTapeHere.setTitle(LocalizedLanguage(key: "btn_tap_here", languageCode: lanCode), for: .normal)
    }
    func ApiPostSavePayment()
    {
        let param : [String:Any] = ["order_id": orderid!,
                                    "order_amount": orderamt,
                                    "transaction_id": transactionid,
                                    "card_number": " ",
                                    "card_type": cardtype,
                                    "card_expiry": cardexpiry,
                                    "first_name": firstname,
                                    "last_name": lastname,
                                    "platform": "iOS"]
        
        self.showHUD()
        let credentialData = "\(user):\(password)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        let base64Credentials = credentialData.base64EncodedString()
        
        let headers = [
            "Authorization": "Basic \(base64Credentials)"]
        
        Alamofire.request(MSavePayment, method: .post, parameters: param, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            self.hideHUD()
            if response.error != nil{
                print(response.error.debugDescription)
                self.showAlert(titleStr: alertMissing, msg: "")
                return
            }
            
            if response.result.value != nil{
                print(response.result.value as Any)
            }
        }
    }

    func SetUI()
    {
        if let ids = DictResponse.value(forKey: "id") as? NSNumber{
            id = ids
        }
        
        if let Method = (DictResponse.value(forKey: "payment_method_id") as? String){
            if Method == "bolbradesco" {
                view_BoletoRecipt.isHidden = false
            }
            else {
                view_BoletoRecipt.isHidden = true
            }
            paymentMethod = Method
        }
        
        if let TempOrderRecipt =  (DictResponse.value(forKey: "transaction_details") as? NSDictionary)?.value(forKey: "external_resource_url") as? String {
            BoletoOrderRecipt = TempOrderRecipt
        }
        
//        if let emailId = (DictResponse.value(forKey: "payer") as? NSDictionary)?.value(forKey: "email") as? String{
//            email = emailId
//        }
        self.lblPaymentNo.text = "\(id)"
        self.lblOrderNo.text = "\(orderid!)"
        self.lblOrderAmt.text = orderamt
        self.lblPaymentMethod.text = paymentMethod
        self.lblEmail.text  = email!
    }
    
    @IBAction func Click_backBtn(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func Click_BoletoRecipt(_ sender: UIButton) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "BoletoOrderCompletVC") as! BoletoOrderCompletVC
        VC.OrderRecipt = BoletoOrderRecipt
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
