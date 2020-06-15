//
//  OrderCompleteVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 04/09/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import AppseeAnalytics
import FBSDKCoreKit
import Firebase

class OrderCompleteVC: BaseViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var lblHeaderOrder: UILabel!
    @IBOutlet weak var lblThankyou: UILabel!
    @IBOutlet weak var lblOrderConfirmed: UILabel!
    @IBOutlet weak var lblPaymentNo: UILabel!
    @IBOutlet weak var lblOrderNo: UILabel!
    @IBOutlet weak var btnTapeHere: UIButton!
    @IBOutlet weak var lblOrderAmt: UILabel!
    @IBOutlet weak var lblPaymentMethod: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var img_Success: UIImageView!
    
    @IBOutlet weak var lbl_TitlePaymentNo: UILabel!
    @IBOutlet weak var lbl_TitleOrderNo: UILabel!
    @IBOutlet weak var lbl_TitleOrderAmount: UILabel!
    @IBOutlet weak var lbl_TitlePaymentMethod: UILabel!
    @IBOutlet weak var lbl_TitleEmail: UILabel!
    
    @IBOutlet weak var btnRateus: UIButton!
    @IBOutlet weak var btnNothanks: UIButton!
   // @IBOutlet weak var lbl_likeourapp: UILabel!
   // @IBOutlet weak var lbl_dialogmessage: UILabel!
    
    //MARK:- variable Declartion
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
    var payment_status: String!
    var BoletoOrderRecipt: String = ""
    var tilesUnit: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults.removeObject(forKey: keyarymain)
        defaults.removeObject(forKey: "promocode")
        setLocalization()
        setDefault()
        
        ApiPostSavePayment()
    }
    
    //MARK:- Private Method
    func setDefault() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = formatter.string(from: Date())
       /* self.img_Success.sd_setShowActivityIndicatorView(true)
        self.img_Success.sd_setIndicatorStyle(.gray)
        self.img_Success.sd_setImage(with: URL(string: "https://www.brickart.com.br/mobile_app/success_page.png?date="+date), completed: nil)*/
        
        if let ids = DictResponse.value(forKey: "id") as? NSNumber{
            id = ids
        }
        
        if let Method = (DictResponse.value(forKey: "payment_method_id") as? String){
            if Method == "bolbradesco" {
                btnTapeHere.isHidden = false
            }
            else {
                btnTapeHere.isHidden = true
            }
            paymentMethod = Method
        }
        
        if let TempOrderRecipt =  (DictResponse.value(forKey: "transaction_details") as? NSDictionary)?.value(forKey: "external_resource_url") as? String {
            BoletoOrderRecipt = TempOrderRecipt
        }
        
        self.lblPaymentNo.text = "\(id)"
        self.lblOrderNo.text = "\(orderid!)"
        self.lblOrderAmt.text = Double(orderamt)!.currencyBR
        self.lblPaymentMethod.text = paymentMethod
        self.lblEmail.text  = email!
    }
    
    func setLocalization() {
        
        self.lblHeaderOrder.text = LocalizedLanguage(key: "lbl_title_order", languageCode: lanCode).uppercased()
        self.lblThankyou.text = LocalizedLanguage(key: "lbl_thank_you", languageCode: lanCode)
        self.lblOrderConfirmed.text = LocalizedLanguage(key: "lbl_your_order_confirmed", languageCode: lanCode)
        self.lbl_TitlePaymentNo.text = LocalizedLanguage(key: "lbl_your_payment_id", languageCode: lanCode)
        self.lbl_TitleOrderNo.text = LocalizedLanguage(key: "lbl_order_id", languageCode: lanCode)
        self.lbl_TitleOrderAmount.text = LocalizedLanguage(key: "lbl_final_amt", languageCode: lanCode)
        self.lbl_TitlePaymentMethod.text = LocalizedLanguage(key: "lbl_payment_method", languageCode: lanCode)
        self.lbl_TitleEmail.text = LocalizedLanguage(key: "txt_email", languageCode: lanCode)
        
       // self.lbl_likeourapp.text = LocalizedLanguage(key: "lbl_dialog_rating_title", languageCode: lanCode)
      //  self.lbl_dialogmessage.text = LocalizedLanguage(key: "txt_dialog_rating_message", languageCode: lanCode)
        
        self.btnTapeHere.setTitle(LocalizedLanguage(key: "btn_tap_here", languageCode: lanCode), for: .normal)
        self.btnRateus.setTitle(LocalizedLanguage(key: "txt_no_rate_us_btn", languageCode: lanCode), for: .normal)
        self.btnNothanks.setTitle(LocalizedLanguage(key: "txt_no_thanks_btn", languageCode: lanCode), for: .normal)
    }
    
    func ApiPostSavePayment() {
        
        let param : [String:Any] = ["order_id": orderid!,
                                    "order_amount": orderamt!,
                                    "transaction_id": transactionid!,
                                    "card_number": "0",
                                    "card_type": cardtype!,
                                    "card_expiry": cardexpiry!,
                                    "first_name": firstname!,
                                    "last_name": lastname!,
                                    "payment_status": payment_status!,
                                    "platform": "iOS"]
//        print(param)
        let credentialData = "\(user):\(password)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        let base64Credentials = credentialData.base64EncodedString()
        
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        
        Alamofire.request(MSavePayment, method: .post, parameters: param, encoding: URLEncoding.default, headers: headers).responseJSON { response in
//            debugPrint(response)
            
            Appsee.addEvent("Purchase", withProperties: [
                "TransactionID" : self.transactionid!,
                "TransactionAmount" : self.orderamt!,
                "PaymentMethodID" : self.cardtype!,
                "Currency" : "BRL",
                "tilesUnit" : self.tilesUnit!,
                "status":self.payment_status!])
            
            FBSDKAppEvents.logPurchase(Double(self.orderamt) ?? 0.0, currency: "BRL", parameters: [
                "TransactionID" : self.transactionid!,
                "TransactionAmount" : self.orderamt!,
                "PaymentMethodID" : self.cardtype!,
                "tilesUnit" : self.tilesUnit!,
                "status":self.payment_status!])
            
            Analytics.logEvent("Purchase", parameters: [
                "TransactionID" : self.transactionid!,
                "TransactionAmount" : self.orderamt!,
                "PaymentMethodID" : self.cardtype!,
                "Currency" : "BRL",
                "tilesUnit" : self.tilesUnit!,
                "status":self.payment_status!])
            
            guard let json = response.result.value else { return }
        }
    }
    
    //MARK:- Button Action
    @IBAction func Click_backBtn(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func Click_helpBtn(_ sender: UIButton) {
        let helpvc = storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
        self.navigationController?.present(helpvc, animated: false, completion: nil)
    }
    
    @IBAction func Click_BoletoRecipt(_ sender: UIButton) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "BoletoOrderCompletVC") as! BoletoOrderCompletVC
        VC.OrderRecipt = BoletoOrderRecipt
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func Click_Rateus(_ sender: UIButton) {
        if let url = URL(string: "https://itunes.apple.com/in/app/id1444716818"),
            UIApplication.shared.canOpenURL(url) {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func Click_Nothanks(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
