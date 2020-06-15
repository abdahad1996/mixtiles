//
//  ReviewAdjustVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 30/08/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import Alamofire
import Photos
import SWXMLHash
import CropViewController
import Firebase
import FBSDKCoreKit
import AppseeAnalytics

class ReviewAdjustVC: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, paymentTokenDelegate, promocodeDiscountDelegate, CropViewControllerDelegate, KACircleCropViewControllerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var vwSuper: UIView!
    @IBOutlet weak var vwHeader: UIView!
    
    @IBOutlet weak var NSLCMoreTileHeight: NSLayoutConstraint!
    @IBOutlet weak var CollectionViewPhoto: UICollectionView!
    @IBOutlet weak var VwMainFrame: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lblAcrilico: UILabel!
    
    @IBOutlet weak var lblTiles: UILabel!
    @IBOutlet weak var lblTotalTilesPrice: UILabel!
    @IBOutlet weak var lblPromoCode: UILabel!
    @IBOutlet weak var lblDicountPrice: UILabel!
    @IBOutlet weak var lblFinalAmount: UILabel!
    @IBOutlet weak var btnConfirmOrder: UIButton!
    @IBOutlet weak var lblMoreTiles: UILabel!
    @IBOutlet weak var lblTotalMoreTilesPrice: UILabel!
    @IBOutlet weak var lblDeliveryDate: UILabel!
    
    @IBOutlet var vwEditPopUp: UIView!
    @IBOutlet weak var vwOptionPopUp: UIView!
    @IBOutlet var vwIntroduction: UIView!
    @IBOutlet weak var imgIntroduction: UIImageView!
    
    @IBOutlet weak var vwCopies: UIView!
    @IBOutlet weak var lblCopies: UILabel!
    @IBOutlet weak var btnmin: UIButton!
    @IBOutlet weak var btnmax: UIButton!
    
    @IBOutlet weak var ColorCollectionView: UICollectionView!
    @IBOutlet weak var lblShipping: UILabel!
    @IBOutlet weak var lblAddShhippingAdd: UILabel!
    @IBOutlet weak var lblAddCreditCard: UILabel!
    @IBOutlet weak var btnAddPromoCode: UIButton!
    
    @IBOutlet weak var btnAdjust: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var btnDismiss: UIButton!
    
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var NSLCNewLineTotalHeight: NSLayoutConstraint!
    
    //MARK:- Variable Declerations
    let locationManager = CLLocationManager()
    
    var arySelectImg = [[String:Any]]()
    var arySelectUpdateImg = NSMutableArray()
    var aryColor = NSMutableArray()
    var aryFrame1 = NSMutableArray()
    var aryFrame = NSMutableArray()
    var aryFullProduct = NSMutableArray()
    var arySpacedProduct = NSMutableArray()
    
    var deleteSelectImg = [[String:Any]]()
    var dictaddress = NSMutableDictionary()
    var appDelegate : AppDelegate = AppDelegate()
    var indexFilter : Int = 101
    var isSelectIndexValue : Int = -1
    
    var TokenId : String = ""
    var paymentId : String = ""
    var promoCode : String = ""
    var discount_type: String = ""
    var discount : String = ""
    var CPF : String = ""
    
    var imgCount : Int = 3
    var souldCallPayment = false
    var isColorSelectIndex : Int = 0
    var SelectFrame : String = "black1"
    var POSTCODE_ORIGIN: String = ""
    
    var ShippingPrice: String = ""
    var ShippingDate : String = ""
    
    var shippingData: XMLIndexer!
    var additional_price: Double = 0
    var mimimun_order_quantity: Int = 0
    var price_for_moq: Double = 0
    
    var GrandTotalAmount : Double = 0.0
    var TempLatLong = 0.0
    
    var isShipping = false
    var isConfirm = false
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefault()
        setLocalization()
        
        self.arySelectImg = self.appDelegate.getUserDetails() as! [[String : Any]]
        self.arySelectUpdateImg = NSMutableArray(array: self.arySelectImg)
        self.CollectionViewPhoto.reloadData()
        
        DispatchQueue.global().async {
            self.getPrice()
        }
    }
    
    //MARK:- viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let token = defaults.value(forKey: keyTokenCreditCard) as? String{
            TokenId = token
        }
        if let paymenttype = defaults.value(forKey: keyPaymentMethod) as? String{
            paymentId = paymenttype
        }
        if let cpf = defaults.value(forKey: keycpfno) as? String{
            CPF = cpf
        }
        
        if (!isShipping) {
            self.getShipping()
        }
        
        isShipping = false
    }
    
    
    //MARK:- Private Method
    func setDefault() {
        NSLCNewLineTotalHeight.constant = 0
        aryColor = [getColorIntoHex(Hex: "000000"), getColorIntoHex(Hex: "F1F1F1"), getColorIntoHex(Hex: "c00000"), getColorIntoHex(Hex: "ffc000"), getColorIntoHex(Hex: "00b069"), getColorIntoHex(Hex: "4472c4")]
        
        aryFrame1 = ["black1","white1","red1","yellow1","green1","blue1"]
        aryFullProduct = ["35","40","37","36","39","38"]
        arySpacedProduct = ["41","42","43","44","45","46"]
        aryFrame = aryFrame1
        ColorCollectionView.reloadData()
        
        //        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        //        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        //        self.view.addGestureRecognizer(swipeDown)
        
        self.vwOptionPopUp.SetRediousView()
        self.vwCopies.SetRediousView()
        self.btnmin.SetRediousBtn()
        self.btnmax.SetRediousBtn()
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizer.Direction.down:
                DispatchQueue.global().async {
                    self.getShipping()
                    self.getPrice()
                }
            default: break
            }
        }
    }
    
    func setLocalization() {
        self.lblHeader.text = LocalizedLanguage(key: "lbl_title_review_adjust", languageCode: lanCode).uppercased()
       // self.lblAcrilico.text = LocalizedLanguage(key: "lbl_colors", languageCode: lanCode)
        self.lblAddShhippingAdd.text = LocalizedLanguage(key: "lbl_add_shipping_address", languageCode: lanCode)
        self.lblAddCreditCard.text = LocalizedLanguage(key: "lbl_add_credit_card", languageCode: lanCode)
        self.btnAdjust.setTitle(LocalizedLanguage(key: "lbl_adjust_popup", languageCode: lanCode), for: .normal)
        self.btnRemove.setTitle(LocalizedLanguage(key: "lbl_remove_popup", languageCode: lanCode), for: .normal)
        self.btnDismiss.setTitle(LocalizedLanguage(key: "lbl_cancel_popup", languageCode: lanCode), for: .normal)
        self.btnConfirmOrder.setTitle(LocalizedLanguage(key: "btn_confirm_order", languageCode: lanCode), for: .normal)
        
        let yourAttributes : [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
        
        let attributeString = NSMutableAttributedString(string: LocalizedLanguage(key: "lbl_title_promo_code", languageCode: lanCode), attributes: yourAttributes)
        self.btnAddPromoCode.setAttributedTitle(attributeString, for: .normal)
    }
    
    //MARK:- API_shipping
    func getShipping() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = formatter.string(from: Date())
        
        Alamofire.request("https://www.brickart.com.br/mobile_app/shipping.txt?date="+date, method: .get, parameters: nil, encoding: JSONEncoding.default).responseString { response in
            if response.error != nil {
//                print(response.error.debugDescription)
                DispatchQueue.main.async {
                    self.TotalAmount()
                }
                return
            }
            
            if response.result.value != nil {
//                print(response.result.value as Any)
                
                let test = String(response.result.value!.filter { !" \n\r".contains($0) }).replacingOccurrences(of: "\'", with: "\"")
                
                let data = test.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                    
                    if let shippingDic = json["data"] as? NSDictionary {
                        defaults.set(shippingDic, forKey: "shipping")
                        defaults.synchronize()
                        
                        var internal_produce_timeindays: Int = 0
                        if let tempItem = shippingDic.value(forKey: "internal_produce_timeindays") as? Double { internal_produce_timeindays = Int(tempItem) }
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let myString = formatter.string(from: Calendar.current.date(byAdding: Calendar.Component.day, value: internal_produce_timeindays, to: Date())!)
                        
                        let dateindate = formatter.date(from: myString)
                        formatter.dateFormat = "EEE MMM d"
                        let dateinstring = formatter.string(from: dateindate!)
                        
                        formatter.dateFormat = "yyyy-MM-dd"
                        self.ShippingDate = formatter.string(from: dateindate!)
                        self.lblShipping.text = "R$ 0"
                        
                        self.lblDeliveryDate.text = "\(LocalizedLanguage(key: "lbl_Deliverd_by", languageCode: lanCode)) " + dateinstring
                        
                        DispatchQueue.main.async {
                            self.TotalAmount()
                        }
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
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
            if response.error != nil {
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
                return
            }
            
            if let json = response.result.value as? NSDictionary {
//                print(response.result.value as Any)
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
                
                if let PriceDic = json["data"] as? NSDictionary {
                    defaults.set(PriceDic, forKey: "price")
                    
                    if let tempItem = PriceDic.value(forKey: "additional_price") as? Double { self.additional_price = tempItem }
                    if let tempItem = PriceDic.value(forKey: "mimimun_order_quantity") as? Int { self.mimimun_order_quantity = tempItem }
                    if let tempItem = PriceDic.value(forKey: "price_for_moq") as? Double { self.price_for_moq = tempItem }
                    
                    DispatchQueue.main.async {
                        self.TotalAmount()
                    }
                }
            }
        }
    }
    
    func CalculateShipping(Total: Double) {
        
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        var internal_produce_timeindays: Int = 0
        var is_allow_free_frieght: Int = 0
        var weight: Double = 0
        var format: Double = 0
        var length: Double = 0
        var height: Double = 0
        var width: Double = 0
        var diameter: Double = 0
        var selfhand: String = ""
        var notice_of_receipt: String = ""
        var postoffice_service_type: String = ""
        var CEP: String = ""
        
        if let ShippingDic = defaults.object(forKey: "shipping") as? NSDictionary {
            if let tempItem = ShippingDic.value(forKey: "internal_produce_timeindays") as? Double { internal_produce_timeindays = Int(tempItem) }
            if let tempItem = ShippingDic.value(forKey: "is_allow_free_frieght") as? Double { is_allow_free_frieght = Int(tempItem) }
            if let tempItem = ShippingDic.value(forKey: "weight") as? Double { weight = tempItem }
            if let tempItem = ShippingDic.value(forKey: "format") as? Double { format = tempItem }
            if let tempItem = ShippingDic.value(forKey: "length") as? Double { length = tempItem }
            if let tempItem = ShippingDic.value(forKey: "height") as? Double { height = tempItem }
            if let tempItem = ShippingDic.value(forKey: "width") as? Double { width = tempItem }
            if let tempItem = ShippingDic.value(forKey: "diameter") as? Double { diameter = tempItem }
            if let tempItem = ShippingDic.value(forKey: "selfhand") as? String { selfhand = tempItem }
            if let tempItem = ShippingDic.value(forKey: "notice_of_receipt") as? String { notice_of_receipt = tempItem }
            if let tempItem = ShippingDic.value(forKey: "postoffice_service_type") as? String { postoffice_service_type = tempItem }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Calendar.current.date(byAdding: Calendar.Component.day, value: internal_produce_timeindays, to: Date())!)
        
        let dateindate = formatter.date(from: myString)
        formatter.dateFormat = "EEE MMM d"
        let dateinstring = formatter.string(from: dateindate!)
        
        self.lblDeliveryDate.text = "\(LocalizedLanguage(key: "lbl_Deliverd_by", languageCode: lanCode)) " + dateinstring
        
        if let TempCEP = (defaults.value(forKey: keydictAddress) as? NSDictionary), ((TempCEP.value(forKey: "cep") as? String) != nil)  {
            CEP = (TempCEP.value(forKey: "cep") as? String)!
        }
        
        let TotalTiles = CalculateTiles(AryName: self.arySelectUpdateImg)
        
        let strUrl = "http://ws.correios.com.br/calculador/CalcPrecoPrazo.aspx?nCdEmpresa=&sDsSenha=&sCepOrigem=04290050&sCepDestino=\(CEP)&nVlPeso=\(weight * TotalTiles)&nCdFormato=\(String(format: "%g", format))&nVlComprimento=\(length)&nVlAltura=\(height * TotalTiles)&nVlLargura=\(width)&sCdMaoPropria=\(selfhand)&nVlValorDeclarado=\(Total)&sCdAvisoRecebimento=\(notice_of_receipt)&nCdServico=\(postoffice_service_type)&nVlDiametro=\(diameter)&StrRetorno=xml&nIndicaCalculo=3"
        
        //          let strUrl = "http://ws.correios.com.br/calculador/CalcPrecoPrazo.aspx?nCdEmpresa=&sDsSenha=&sCepOrigem=04290050&sCepDestino=23080060&nVlPeso=1.2000000000000002&nCdFormato=1&nVlComprimento=20.5&nVlAltura=3.0&nVlLargura=20.5&sCdMaoPropria=s&nVlValorDeclarado=0.0&sCdAvisoRecebimento=n&nCdServico=41106&nVlDiametro=0&StrRetorno=xml&nIndicaCalculo=3"
        
//        print(strUrl)
        
        Alamofire.request(strUrl).response { (response) in
            
            ApiUtillity.sharedInstance.dismissSVProgressHUD()
            let data = response.data!
            
            let xml = SWXMLHash.parse(data)
//            print(xml)
            
            if let dic = (xml["Servicos"] as? XMLIndexer), dic.children.count > 0 {
                self.shippingData = dic.children.min { $0["PrazoEntrega"].element!.text < $1["PrazoEntrega"].element!.text }!
                //            print(self.shippingData)
                
                if is_allow_free_frieght == 1 {
                    self.lblShipping.text = LocalizedLanguage(key: "lbl_free", languageCode: lanCode)
                    self.lblFinalAmount.text = (self.promoCode == "") ? LocalizedLanguage(key: "lbl_total", languageCode: lanCode) + Total.currencyBR : ""
                    self.lblTotal.text = LocalizedLanguage(key: "lbl_total", languageCode: lanCode) + Total.currencyBR
                }
                else {
                    self.ShippingPrice = (self.shippingData["ValorSemAdicionais"].element?.text)!.replacingOccurrences(of: ",", with: ".")
                    
                    if (self.shippingData) != nil {
                        let shippingDay = self.shippingData["PrazoEntrega"].element?.text
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let myString = formatter.string(from: Calendar.current.date(byAdding: Calendar.Component.day, value: (Int(shippingDay!)! + internal_produce_timeindays), to: Date())!)
                        
                        let dateindate = formatter.date(from: myString)
                        formatter.dateFormat = "EEE MMM d"
                        let dateinstring = formatter.string(from: dateindate!)
                        
                        self.lblDeliveryDate.text = "\(LocalizedLanguage(key: "lbl_Deliverd_by", languageCode: lanCode)) " + dateinstring
                    }
                    
                    let shipping = self.shippingCalculation(price: self.ShippingPrice)
                    
                    self.lblShipping.text = shipping.currencyBR
                    self.lblFinalAmount.text = (self.promoCode == "") ? LocalizedLanguage(key: "lbl_total", languageCode: lanCode) + Double(Total + shipping).currencyBR : ""
                    self.lblTotal.text = LocalizedLanguage(key: "lbl_total", languageCode: lanCode) + Double(Total + shipping).currencyBR
                }
            }
        }
    }
    
    @IBAction func Click_BackBtn(_ sender: UIButton) {
        isReloadCollectionView = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Click_dismissIntroduction(_ sender: UIButton) {
        self.vwIntroduction.removeFromSuperview()
    }
    @IBAction func Click_dismissBtn(_ sender: UIButton) {
        self.TotalAmount()
        self.vwEditPopUp.removeFromSuperview()
    }
    
    @IBAction func Click_removeBtn(_ sender: UIButton) {
        
        var TotalTiles = Int()
        for (index,item) in self.arySelectUpdateImg.enumerated() {
            var copy = (item as! NSDictionary).value(forKey: "copy") as! Int
            if isSelectIndexValue == index {
                copy = 1
            }
            TotalTiles += copy
        }
        
        if TotalTiles > mimimun_order_quantity {
            var Dict = self.arySelectImg[isSelectIndexValue]
            let indexpath = Dict["SelectIndex"] as! Int
            let MainDict = MainAry.object(at: indexpath) as! [String:Any]
            let AryImg = MainDict["\(AryCategoryList[indexpath])"] as! NSMutableArray
            
            let selectId = Dict["id"] as! String
            for i in 0..<AryImg.count{
                let id = (AryImg.object(at: i) as! NSDictionary).value(forKey: "id") as! String
                if id == selectId{
                    Dict.updateValue(false, forKey: "is_select")
                    Dict.updateValue(1, forKey: "copy")
                    AryImg.replaceObject(at: i, with: Dict)
                    let MainDict1 = MainAry.object(at: indexpath) as! [String:Any]
                    MainAry.replaceObject(at: indexpath, with: MainDict1)
                    break
                }
            }
            
            arySelectImg.remove(at: isSelectIndexValue)
            arySelectUpdateImg.removeObject(at: isSelectIndexValue)
            let userdict = NSKeyedArchiver.archivedData(withRootObject: arySelectImg)
            defaults.setValue(userdict, forKey: keyarymain)
            defaults.synchronize()
            
            CollectionViewPhoto.reloadData()
            self.TotalAmount()
            self.vwEditPopUp.removeFromSuperview()
        }
        else {
            self.showAlert(titleStr: "\(LocalizedLanguage(key: "alert_select_at_least", languageCode: lanCode)) \(self.mimimun_order_quantity) \(LocalizedLanguage(key: "alert_photos", languageCode: lanCode))", msg: "")
        }
    }
    
    @IBAction func Click_adjustBtn(_ sender: UIButton) {
        var Dict = self.arySelectImg[isSelectIndexValue]
        var ImgConvert = UIImage()
        
        requestOption.isSynchronous = true
        requestOption.resizeMode = .exact
        requestOption.deliveryMode = .fastFormat
        requestOption.isNetworkAccessAllowed = true
        
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [Dict["id"] as! String], options: .none).firstObject
        imgManager.requestImage(for: asset!, targetSize: CGSize(width: asset!.pixelWidth, height: asset!.pixelHeight), contentMode: .aspectFit, options: requestOption, resultHandler: { result, info in
            ImgConvert = result!
        })
        
        let circleCropController = KACircleCropViewController(withImage: ImgConvert)
        circleCropController.delegate = self
        
        self.present(circleCropController, animated: false, completion: nil)
    }
    
    func circleCropDidCancel() {
        //Basic dismiss
        dismiss(animated: false, completion: nil)
    }
    
    func circleCropDidCropImage(_ image: UIImage) {
        let Imgconvert = self.ResizeImage(image: image, targetSize: CGSize(width: image.size.width, height: image.size.height))
        
        var Dict = self.arySelectUpdateImg[isSelectIndexValue] as! [String:Any]
        Dict.updateValue(Imgconvert, forKey: "img")
        self.arySelectUpdateImg.replaceObject(at: isSelectIndexValue, with: Dict)
        /*
         self.arySelectImg[self.isSelectIndexValue] = Dict
         let userdict = NSKeyedArchiver.archivedData(withRootObject: self.arySelectImg)
         defaults.setValue(userdict, forKey: keyarymain)
         */
        CollectionViewPhoto.reloadData()
        
        self.isShipping = true
        self.vwEditPopUp.removeFromSuperview()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func Click_plusCopyBtn(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            var Dict = self.arySelectUpdateImg[self.isSelectIndexValue] as! [String:Any]
            
            let indexPath = IndexPath(item: self.isSelectIndexValue, section: 0)
            let Cell : Review_Cell = self.CollectionViewPhoto.cellForItem(at: indexPath) as! Review_Cell
            
            if var copyimg = Dict["copy"] as? Int{
                if sender.tag == 502{
                    if copyimg < 99 {
                        copyimg = copyimg + 1
                        if copyimg > 1 {
                            Cell.countOuterview.isHidden = false
                            Cell.LblCount.text = "\(copyimg)"
                            self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copies", languageCode: lanCode))"
                        }
                        else{
                            Cell.countOuterview.isHidden = true
                            Cell.LblCount.text = "\(copyimg)"
                            self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copy", languageCode: lanCode))"
                        }
                    }
                    else {
                        Cell.LblCount.isHidden = false
                        Cell.LblCount.text = "\(copyimg)"
                        self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copy", languageCode: lanCode))"
                        self.shakeAnimation(vwName: self.vwCopies)
                    }
                }
                else {
                    let TotalTiles = Int(self.CalculateTiles(AryName: self.arySelectUpdateImg))
                    if TotalTiles <= self.mimimun_order_quantity {
                        self.shakeAnimation(vwName: self.vwCopies)
                    }
                    else {
                        if copyimg > 1 {
                            copyimg = copyimg - 1
                            if copyimg > 1 {
                                Cell.countOuterview.isHidden = false
                                Cell.LblCount.text = "\(copyimg)"
                                self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copies", languageCode: lanCode))"
                            }
                            else{
                                Cell.countOuterview.isHidden = true
                                Cell.LblCount.text = "\(copyimg)"
                                self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copy", languageCode: lanCode))"
                            }
                        }
                        else{
                            Cell.countOuterview.isHidden = true
                            Cell.LblCount.text = "\(copyimg)"
                            self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copy", languageCode: lanCode))"
                            self.shakeAnimation(vwName: self.vwCopies)
                        }
                    }
                }
            }
            
            let indexpathselect = Dict["SelectIndex"] as! Int
            let MainDict = MainAry.object(at: indexpathselect) as! [String:Any]
            let AryImg = MainDict["\(AryCategoryList[indexpathselect])"] as! NSMutableArray
            
            let selectId = Dict["id"] as! String
            for i in 0..<AryImg.count{
                
                let id = (AryImg.object(at: i) as! NSDictionary).value(forKey: "id") as! String
                if id == selectId{
                    Dict.updateValue(Int(Cell.LblCount.text!) ?? 0, forKey: "copy")
                    AryImg.replaceObject(at: i, with: Dict)
                    let MainDict1 = MainAry.object(at: indexpathselect) as! [String:Any]
                    MainAry.replaceObject(at: indexpathselect, with: MainDict1)
                    break
                }
            }
            
            self.arySelectImg[self.isSelectIndexValue] = Dict
            self.arySelectUpdateImg.replaceObject(at: self.isSelectIndexValue, with: Dict)
            let userdict = NSKeyedArchiver.archivedData(withRootObject: self.arySelectImg)
            defaults.setValue(userdict, forKey: keyarymain)
            defaults.synchronize()
        }
    }
    
    @IBAction func Click_helpBtn(_ sender: UIButton) {
        let helpvc = storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
        self.navigationController?.present(helpvc, animated: false, completion: nil)
    }
    
    @IBAction func Click_addCreditCardBtn(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddCreditCardVC") as! AddCreditCardVC
        vc.delegate = self
        vc.isShippingSet = {(str) in
            self.isShipping = str
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func Click_addShippingAdd(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddAddressVC") as! AddAddressVC
        vc.ReviewAndAdjust = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func Click_AddPromocodeBtn(_ sender: UIButton) {
        let AddPromoVC = storyboard?.instantiateViewController(withIdentifier: "AddPromoCodeVC") as! AddPromoCodeVC
        AddPromoVC.delegate = self
        self.navigationController?.pushViewController(AddPromoVC, animated: true)
    }
    
    func paymentToken(token: String, paymentid: String, cpf: String) {
        self.TokenId = token
        self.paymentId = paymentid
        self.CPF = cpf
    }
    
    func promocodeDicount(discount_type: String, discount: String, promoCode: String) {
        self.promoCode = promoCode
        self.discount_type = discount_type
        self.discount = discount
        self.TotalAmount()
    }
    
    func TotalAmount() {
        
        let PromoCode: String = !promoCode.isEmpty ? "(\(promoCode))" : ""
        let TotalTiles = CalculateTiles(AryName: self.arySelectUpdateImg)
        let minimumQuantity: Double = Double(mimimun_order_quantity)
        
        let minimumOrderAmount: Double = price_for_moq
        let additionalOrderAmount: Double = (TotalTiles - minimumQuantity) * additional_price
        GrandTotalAmount = minimumOrderAmount + additionalOrderAmount
        
        let shipping = shippingCalculation(price: self.ShippingPrice)
        
        var Discount: Double = 0
        if discount_type == "percent" {
            Discount = !discount.isEmpty ? (((GrandTotalAmount + shipping) * Double(discount)!) / 100) : 0
        }
        else {
            Discount = !discount.isEmpty ? Double(discount)! : 0
        }
        
        self.lblTiles.text = String(mimimun_order_quantity) + " " + LocalizedLanguage(key: "lbl_tiles_for", languageCode: lanCode) + " " + price_for_moq.currencyBR
        
        self.lblTotalTilesPrice.text = price_for_moq.currencyBR
        
        self.lblMoreTiles.text = (TotalTiles - minimumQuantity) != 0 ? String(format: "%g", TotalTiles - minimumQuantity) + " " + LocalizedLanguage(key: "lbl_more_tiles", languageCode: lanCode) + " " + additional_price.currencyBR + " " + LocalizedLanguage(key: "lbl_each", languageCode: lanCode) : ""
        NSLCMoreTileHeight.constant = (TotalTiles - minimumQuantity) != 0 ? 25 : 0
        
        self.lblTotalMoreTilesPrice.text = (TotalTiles - minimumQuantity) != 0 ? ((TotalTiles - minimumQuantity) * additional_price).currencyBR : ""
        self.lblPromoCode.text = PromoCode
        self.lblDicountPrice.text = Discount != 0 ? "-"+Discount.currencyBR : ""
        self.lblFinalAmount.text = (Discount != 0) ? "" : LocalizedLanguage(key: "lbl_total", languageCode: lanCode) + ((GrandTotalAmount + shipping) - Discount).currencyBR
        self.NSLCNewLineTotalHeight.constant = (Discount != 0) ? 25 : 0
        if defaults.value(forKey: keydictAddress) != nil {
            if Reachability.isConnectedToNetwork() {
                self.CalculateShipping(Total: GrandTotalAmount - Discount)
            }
            else {
                self.showAlert(titleStr: LocalizedLanguage(key: "alert_network", languageCode: lanCode), msg: "")
            }
        }
        else {
          //  self.lblFinalAmount.text = LocalizedLanguage(key: "lbl_total", languageCode: lanCode) + ((GrandTotalAmount + shipping) - Discount).currencyBR
            self.lblFinalAmount.text = (Discount != 0) ? "" : LocalizedLanguage(key: "lbl_total", languageCode: lanCode) + ((GrandTotalAmount + shipping) - Discount).currencyBR
            self.lblTotal.text = LocalizedLanguage(key: "lbl_total", languageCode: lanCode) + ((GrandTotalAmount + shipping) - Discount).currencyBR
        }
    }
    
    func shippingCalculation(price: String) -> Double {
        if price == "" || price == "GRÁTIS" {
            return 0
        } else {
            return Double(price)!
        }
    }
    
    func CalculateTiles(AryName : NSMutableArray) -> Double {
        var finalTilesCnt = Int()
        for item in AryName {
            let copy = (item as! NSDictionary).value(forKey: "copy") as! Int
            finalTilesCnt = finalTilesCnt + copy
        }
        return Double(finalTilesCnt)
    }
    
    func shakeAnimation(vwName: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: vwName.center.x - 10, y: vwName.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: vwName.center.x + 10, y: vwName.center.y))
        
        vwName.layer.add(animation, forKey: "position")
    }
    
    func AddSubViewtoParentView(parentview: UIView! , subview: UIView!) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        parentview.addSubview(subview);
        parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0))
        parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
        parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0))
        parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
        parentview.layoutIfNeeded()
    }
    
    @IBAction func Click_ConfirmOrder(_ sender: UIButton) {
        if isConfirm {
            return
        }
        isConfirm = true
        
        let Cnt = Int(CalculateTiles(AryName: arySelectUpdateImg))
        if Cnt >= mimimun_order_quantity {
            if defaults.value(forKey: keydictAddress) == nil {
                self.isConfirm = false
                showAlert(titleStr: LocalizedLanguage(key: "alert_add_shipping_address", languageCode: lanCode), msg: "")
            }
            else {
                if self.paymentId.isEmpty || defaults.value(forKey: keyTokenCreditCard) == nil && self.paymentId != "bolbradesco" {
                    self.isConfirm = false
                    showAlert(titleStr: LocalizedLanguage(key: "alert_add_credit_card_details", languageCode: lanCode), msg: "")
                }
                else {
                    ApiUtillity.sharedInstance.showSVProgressHUD(text: "Enviando imagens")
                    var ImgCnt = 0
                    if arySelectUpdateImg.count <= 3 {
                        ImgCnt = arySelectUpdateImg.count
                    }
                    else {
                        ImgCnt = 3
                    }
                    
                    let param : NSMutableDictionary = NSMutableDictionary()
                    for i in 0..<ImgCnt{
                        
                        let dictImg = arySelectUpdateImg[i] as! NSDictionary
                        var squareImg = UIImage()
                        var selectedImg = UIImage()
                        var size: Int = 0
                        
                        if let resizeImg = dictImg["img"] as? UIImage {
                            
                            if resizeImg.size.width > 1200 && resizeImg.size.height > 1200 {
                                size = 1000
                            } else {
                                size = 800
                            }
                            squareImg = resizeImg
                        }
                        else {
                            requestOption.isSynchronous = true
                            requestOption.resizeMode = .exact
                            requestOption.deliveryMode = .highQualityFormat
                            requestOption.isNetworkAccessAllowed = true
                            
                            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [dictImg.value(forKey: "id") as! String], options: .none).firstObject
                            imgManager.requestImage(for: asset!, targetSize: CGSize(width: asset!.pixelWidth, height: asset!.pixelHeight), contentMode: .aspectFit, options: requestOption, resultHandler: { result, info in
                                
                                
                                if asset!.pixelWidth > 1200 && asset!.pixelHeight > 1200 {
                                    size = 1000
                                } else {
                                    size = 800
                                }
//                                print(asset!.pixelWidth, asset!.pixelHeight, size)
                                
                                squareImg = self.RBSquareImage(image: result!)
                            })
                        }
                        
                        let rect = CGRect(x: 0, y: 0, width: size, height: size)
                        
                        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 1.0)
                        squareImg.draw(in: rect)
                        let finalImg = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        if let source = finalImg, let cgSource = source.cgImage {
                            selectedImg = UIImage(cgImage: cgSource, scale: 150.0 / 72.0, orientation: source.imageOrientation)
                        }
                        
                        var productId = String()
                        if indexFilter == 101 {
                            productId = "\(aryFullProduct.object(at: isColorSelectIndex) as! String)"
                        }
                        else{
                            productId = "\(arySpacedProduct.object(at: isColorSelectIndex) as! String)"
                        }
                        
                        let base64 = convertImageToBase64(image: selectedImg)
                        let copy = dictImg.value(forKey: "copy") as! Int
                        
                        param.setValue(price_for_moq / Double(mimimun_order_quantity), forKey: "tiles_details[\(i)][price]")
                        param.setValue(productId, forKey: "tiles_details[\(i)][product_id]")
                        param.setValue("set", forKey: "tiles_details[\(i)][product_type]")
                        param.setValue("25", forKey: "tiles_details[\(i)][product_size]")
                        param.setValue(base64, forKey: "tiles_details[\(i)][image_base64]")
                        param.setValue(copy, forKey: "tiles_details[\(i)][tiles_copy]")
                    }
                    
                    let dictAdd = defaults.value(forKey: keydictAddress) as! NSDictionary
                    let StreetAddandNo = "\(dictAdd.value(forKey: "address") as! String), \(dictAdd.value(forKey: "streetno") as! String)"
                    
                    var firstname: String = ""
                    var lastname: String = ""
                    let fullname = (dictAdd.value(forKey: "fullname") as! String).components(separatedBy: " ")
                    if fullname.count > 1 {
                        firstname = fullname[0]
                        lastname = fullname[1]
                    }
                    else {
                        firstname = fullname[0]
                        lastname = ""
                    }
                    
                    let shipping = shippingCalculation(price: self.ShippingPrice)
                    
                    param.setValue(firstname, forKey: "first_name")
                    param.setValue(lastname, forKey: "last_name")
                    
                    param.setValue(1, forKey: "user_id")
                    param.setValue((GrandTotalAmount + shipping), forKey: "total_tiles_price")
                    param.setValue(dictAdd.value(forKey: "email") as! String, forKey: "email")
                    param.setValue(StreetAddandNo, forKey: "street_address")
                    param.setValue(defaults.value(forKey: keycpfno) as! String, forKey: "cpf")
                    param.setValue(dictAdd.value(forKey: "cep") as! String, forKey: "postal_code")
                    param.setValue(dictAdd.value(forKey: "phoneno") as! String, forKey: "phone_number")
                    param.setValue(dictAdd.value(forKey: "city") as! String, forKey: "city")
                    param.setValue(dictAdd.value(forKey: "state") as! String, forKey: "state")
                    param.setValue(self.promoCode, forKey: "promo_code")
                    param.setValue("\(ShippingDate)", forKey: "delivery_date")
                    param.setValue("\(shipping)", forKey: "shipping_price")
                    
                    if let uid = UserDefaults.standard.value(forKey: "onesignalUID") as? String {
                        param.setValue(uid, forKey: "Onesignal_uid")
                    }
                    
//                    print(param)
                    if Reachability.isConnectedToNetwork(){
                        ApiPostTilesinfo(dict: param)
                    }
                    else {
                        self.isConfirm = false
                        self.showAlert(titleStr: LocalizedLanguage(key: "alert_network", languageCode: lanCode), msg: "")
                        ApiUtillity.sharedInstance.dismissSVProgressHUD()
                    }
                }
            }
        }
        else {
            isConfirm = false
            showAlert(titleStr: "\(mimimun_order_quantity - Cnt) \(LocalizedLanguage(key: "alert_more_tiles_needed", languageCode: lanCode))", msg: LocalizedLanguage(key: "alert_brickart", languageCode: lanCode))
        }
    }
    
    func ApiPostTilesinfo(dict : NSDictionary)
    {
        let credentialData = "\(user):\(password)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        let base64Credentials = credentialData.base64EncodedString()
        
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        let param = dict as! [String:Any]
//        print(param)
        Alamofire.request(Msendtilesinfo, method: .post, parameters: param, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            
            switch response.result {
            case .success:
                if response.result.value != nil {
                    let ResponseDict = response.result.value as! NSDictionary
                    if let status = ResponseDict.value(forKey: "status") as? Bool{
                        if status == true {
                            let data = ResponseDict.value(forKey: "data") as! NSDictionary
                            DispatchQueue.main.async(execute: {
                                if self.arySelectUpdateImg.count > 3 {
                                    if let orderid = ((data.value(forKey: "order") as? NSArray)?.object(at: 0) as! NSDictionary).value(forKey: "order_id") as? String {
                                        self.ApiUpdateOrderTiles(order_id : orderid)
                                    }
                                }
                                else{
                                    self.ApiPostPayment(dict: data)
                                }
                            })
                        }
                        else {
                            self.isConfirm = false
                            ApiUtillity.sharedInstance.dismissSVProgressHUD()
                            self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                        }
                    }
                    else {
                        self.isConfirm = false
                        ApiUtillity.sharedInstance.dismissSVProgressHUD()
                        self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                    }
                }
            case .failure(let error):
                print(error)
                self.isConfirm = false
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
                self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                return
            }
        }
    }
    
    func ApiUpdateOrderTiles(order_id: String)
    {
        var imgCnt = 0
        if (arySelectUpdateImg.count)-3 <= imgCount {
            imgCnt = arySelectUpdateImg.count - imgCount
            souldCallPayment = true
        }
        else {
            imgCnt = 3
        }
        
        let param : NSMutableDictionary = NSMutableDictionary()
        for i in imgCount..<imgCount + imgCnt {
            
            let dictImg = arySelectUpdateImg[i] as! NSDictionary
            var squareImg = UIImage()
            var selectedImg = UIImage()
            var size: Int = 0
            
            if let resizeImg = dictImg["img"] as? UIImage {
                
                if resizeImg.size.width > 1200 && resizeImg.size.height > 1200 {
                    size = 1000
                } else {
                    size = 800
                }
                squareImg = resizeImg
            }
            else {
                requestOption.isSynchronous = true
                requestOption.resizeMode = .exact
                requestOption.deliveryMode = .highQualityFormat
                requestOption.isNetworkAccessAllowed = true
                
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [dictImg.value(forKey: "id") as! String], options: .none).firstObject
                imgManager.requestImage(for: asset!, targetSize: CGSize(width: asset!.pixelWidth, height: asset!.pixelHeight), contentMode: .aspectFit, options: requestOption, resultHandler: { result, info in
                    
                    if asset!.pixelWidth > 1200 && asset!.pixelHeight > 1200 {
                        size = 1000
                    } else {
                        size = 800
                    }
//                    print(asset!.pixelWidth, asset!.pixelHeight, size)
                    
                    squareImg = self.RBSquareImage(image: result!)
                })
            }
            
            let rect = CGRect(x: 0, y: 0, width: size, height: size)
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 1.0)
            squareImg.draw(in: rect)
            let finalImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let source = finalImg, let cgSource = source.cgImage {
                selectedImg = UIImage(cgImage: cgSource, scale: 150.0 / 72.0, orientation: source.imageOrientation)
            }
            
            var productId = String()
            if indexFilter == 101 {
                productId = "\(aryFullProduct.object(at: isColorSelectIndex) as! String)"
            }
            else{
                productId = "\(arySpacedProduct.object(at: isColorSelectIndex) as! String)"
            }
            
            let base64 = convertImageToBase64(image: selectedImg)
            let copy = dictImg.value(forKey: "copy") as! Int
            
            if imgCount < mimimun_order_quantity {
                param.setValue(price_for_moq / Double(mimimun_order_quantity), forKey: "tiles_details[\(i)][price]")
            }
            else {
                param.setValue(additional_price, forKey: "tiles_details[\(i)][price]")
            }
            
            param.setValue(productId, forKey: "tiles_details[\(i)][product_id]")
            param.setValue("set", forKey: "tiles_details[\(i)][product_type]")
            param.setValue("25", forKey: "tiles_details[\(i)][product_size]")
            param.setValue(base64, forKey: "tiles_details[\(i)][image_base64]")
            param.setValue(copy, forKey: "tiles_details[\(i)][tiles_copy]")
        }
        param.setValue(1, forKey: "user_id")
        param.setValue(order_id, forKey: "order_id")
        //        print(param)
        if Reachability.isConnectedToNetwork(){
            ApiPostUpdateOrderTiles(dict: param)
        }
        else {
            isConfirm = false
            self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
        }
    }
    
    func ApiPostUpdateOrderTiles(dict: NSDictionary)
    {
        let credentialData = "\(user):\(password)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        let base64Credentials = credentialData.base64EncodedString()
        
        let headers = [
            "Authorization": "Basic \(base64Credentials)"]
        let param = dict as! [String:Any]
        //        print(param)
        
        Alamofire.request(MupdateOrderTiles, method: .post, parameters: param, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            
            switch response.result{
            case .success:
                if response.result.value != nil{
                    let ResponseDict = response.result.value as! NSDictionary
                    if let status = ResponseDict.value(forKey: "status") as? Bool{
                        if status == true {
                            let data = ResponseDict.value(forKey: "data") as! NSDictionary
                            DispatchQueue.main.async(execute: {
                                self.imgCount += 3
                                if (self.souldCallPayment == true || self.imgCount == self.arySelectUpdateImg.count) {
                                    self.imgCount = 3
                                    self.ApiPostPayment(dict: data)
                                }
                                else {
                                    if let orderid = ((data.value(forKey: "order") as? NSArray)?.object(at: 0) as! NSDictionary).value(forKey: "order_id") as? String {
                                        
                                        DispatchQueue.main.async(execute: {
                                            self.ApiUpdateOrderTiles(order_id : orderid)
                                        })
                                    }
                                }
                            })
                        }
                        else{
                            ApiUtillity.sharedInstance.dismissSVProgressHUD()
                            self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                        }
                    }
                    else{
                        ApiUtillity.sharedInstance.dismissSVProgressHUD()
                        self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                    }
                    //                    print(ResponseDict)
                }
                
            case .failure(let error):
                print(error)
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
                self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                return
            }
        }
    }
    
    func ApiPostPayment(dict : NSDictionary) {
        
        let AryOrder  = dict.value(forKey: "order") as! NSArray
        let TempDict = NSMutableDictionary()
        
        var firstname: String = ""
        var lastname: String = ""
        
        let TotalTiles = Int(CalculateTiles(AryName: arySelectUpdateImg))
        
        let shipping = shippingCalculation(price: self.ShippingPrice)
        
        var Discount: Double = 0
        if discount_type == "percent" {
            Discount = !discount.isEmpty ? (((GrandTotalAmount + shipping) * Double(discount)!) / 100) : 0
        }
        else {
            Discount = !discount.isEmpty ? Double(discount)! : 0
        }
        
        if self.paymentId == "bolbradesco" {
            
            TempDict.setValue(((GrandTotalAmount + shipping).roundToDecimal(2) - Discount).roundToDecimal(2), forKey: "transaction_amount")
            TempDict.setValue("BrickArt order - \(TotalTiles) units", forKey: "description")
            TempDict.setValue(self.paymentId, forKey: "payment_method_id")
            
            let payerDict = NSMutableDictionary()
            payerDict.setValue((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "email") as! String, forKey: "email")
            
            let fullname = ((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "fullname") as! String).components(separatedBy: " ")
            if fullname.count > 1 {
                firstname = fullname[0]
                lastname = fullname[1]
            }
            else {
                firstname = fullname[0]
                lastname = fullname[0]
            }
            payerDict.setValue(firstname, forKey: "first_name")
            payerDict.setValue(lastname, forKey: "last_name")
            
            let identificationDict = NSMutableDictionary()
            identificationDict.setValue("CPF", forKey: "type")
            identificationDict.setValue(defaults.value(forKey: keycpfno) as! String, forKey: "number")
            payerDict.setValue(identificationDict, forKey: "identification")
            
            let addressDict = NSMutableDictionary()
            addressDict.setValue((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "cep") as! String, forKey: "zip_code")
            addressDict.setValue((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "address") as! String, forKey: "street_name")
            addressDict.setValue((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "streetno") as! String, forKey: "street_number")
            addressDict.setValue((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "neighborhood") as! String, forKey: "neighborhood")
            addressDict.setValue((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "city") as! String, forKey: "city")
            addressDict.setValue((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "state") as! String, forKey: "federal_unit")
            payerDict.setValue(addressDict, forKey: "address")
            
            TempDict.setValue(payerDict, forKey: "payer")
        }
        else {
            TempDict.setValue((((GrandTotalAmount + shipping).roundToDecimal(2)) - Discount).roundToDecimal(2), forKey: "transaction_amount")
            TempDict.setValue(self.TokenId, forKey: "token")
            TempDict.setValue("BrickArt order - \(TotalTiles) units", forKey: "description")
            TempDict.setValue(self.paymentId, forKey: "payment_method_id")
            //TempDict.setValue(3, forKey: "installments")//TempDict.setValue(1, forKey: "installments")
            if let installment = defaults.value(forKey: keySelectedInstallment) as? String
            {
                TempDict.setValue(Int(installment), forKey: "installments")
            }
            else
            {
                TempDict.setValue(1, forKey: "installments")
            }
            
            let payerDict = NSMutableDictionary()
            payerDict.setValue((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "email") as! String, forKey: "email")
            
            let fullname = ((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "fullname") as! String).components(separatedBy: " ")
            if fullname.count > 1 {
                firstname = fullname[0]
                lastname = fullname[1]
            }
            else {
                firstname = fullname[0]
                lastname = fullname[0]
            }
            payerDict.setValue(firstname, forKey: "first_name")
            payerDict.setValue(lastname, forKey: "last_name")
            
            TempDict.setValue(payerDict, forKey: "payer")
            TempDict.setValue("\(Date().millisecondsSince1970)", forKey: "external_reference")
        }
        
        print(TempDict)
        
        Alamofire.request(Mpayments, method: .post, parameters: (TempDict as! [String:Any]), encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            defaults.removeObject(forKey: keyTokenCreditCard)
            
            let TotalTiles = Int(self.CalculateTiles(AryName: self.arySelectUpdateImg))
            
            if response.error != nil {
                self.isConfirm = false
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
                self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                return
            }
            
            var email = String()
            var cardTypes = String()
            var expirymonth = Int()
            var expiryyear = Int()
            
            if response.result.value != nil {
                let ResponseDict = response.result.value as! NSDictionary
                print(ResponseDict)
                if let status = ResponseDict.value(forKey: "status") as? String {
                    
                    if let fname = (ResponseDict.value(forKey: "payer") as? NSDictionary)?.value(forKey: "first_name") as? String {
                        firstname = fname
                    }
                    
                    if let lname = (ResponseDict.value(forKey: "payer") as? NSDictionary)?.value(forKey: "last_name") as? String {
                        lastname = lname
                    }
                    
                    if let cardtype = ResponseDict.value(forKey: "payment_method_id") as? String {
                        cardTypes = cardtype
                    }
                    
                    if let emonth = (ResponseDict.value(forKey: "card") as? NSDictionary)?.value(forKey: "expiration_month") as? Int{
                        expirymonth = emonth
                    }
                    
                    if let eyear = (ResponseDict.value(forKey: "card") as? NSDictionary)?.value(forKey: "expiration_year") as? Int{
                        expiryyear = eyear
                    }
                    
                    if let Tempemail = (defaults.value(forKey: keydictAddress) as? NSDictionary)?.value(forKey: "email") as? String{
                        email = Tempemail
                    }
                    
                    if status == "approved" || status == "authorized" || status == "pending" || status == "in_process" {
                        
                        ApiUtillity.sharedInstance.dismissSVProgressHUD()
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderCompleteVC") as! OrderCompleteVC
                        vc.orderid = (AryOrder[0] as! NSDictionary).value(forKey: "order_id") as? String
                        vc.orderamt = "\((self.GrandTotalAmount + shipping) - Discount)"
                        vc.transactionid = ResponseDict.value(forKey: "id") as? NSNumber
                        vc.cardtype = cardTypes
                        vc.cardexpiry = "\(expirymonth)/\(expiryyear)"
                        vc.firstname = firstname
                        vc.lastname = lastname
                        vc.email = email
                        vc.payment_status = status
                        vc.DictResponse =  NSMutableDictionary(dictionary: ResponseDict)
                        vc.tilesUnit = TotalTiles
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else if status == "rejected" || status == "cancelled" {
                        self.isConfirm = false
                        ApiUtillity.sharedInstance.dismissSVProgressHUD()
                        self.showAlert(titleStr: LocalizedLanguage(key: "txt_payment_rejected", languageCode: lanCode), msg: "")
                        
                        self.ApiPostSavePayment(orderid: (AryOrder[0] as! NSDictionary).value(forKey: "order_id") as! String, orderamt: "\((self.GrandTotalAmount + shipping) - Discount)", transactionid: "\(ResponseDict.value(forKey: "id") as! NSNumber)", cardtype: cardTypes, cardexpiry: "\(expirymonth)/\(expiryyear)", firstname: firstname, lastname: lastname, payment_status: status, tilesUnit: TotalTiles)
                    }
                    else {
                        self.isConfirm = false
                        ApiUtillity.sharedInstance.dismissSVProgressHUD()
                        self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                        
                        self.ApiPostSavePayment(orderid: (AryOrder[0] as! NSDictionary).value(forKey: "order_id") as! String, orderamt: "\((self.GrandTotalAmount + shipping) - Discount)", transactionid: "\(ResponseDict.value(forKey: "id") as! NSNumber)", cardtype: cardTypes, cardexpiry: "\(expirymonth)/\(expiryyear)", firstname: firstname, lastname: lastname, payment_status: !status.isEmpty ? status : "", tilesUnit: TotalTiles)
                    }
                }
                else {
                    self.isConfirm = false
                    ApiUtillity.sharedInstance.dismissSVProgressHUD()
                    self.showAlert(titleStr: "\(ResponseDict.value(forKey: "message") as! String)", msg: "")
                }
            }
        }
    }
    
    func ApiPostSavePayment(orderid: String, orderamt: String, transactionid: String, cardtype: String, cardexpiry: String, firstname: String, lastname: String, payment_status: String, tilesUnit: Int) {
        
        let param : [String:Any] = ["order_id": orderid,
                                    "order_amount": orderamt,
                                    "transaction_id": transactionid,
                                    "card_number": "xxxxxxxxxxxxxxxx",
                                    "card_type": cardtype,
                                    "card_expiry": cardexpiry,
                                    "first_name": firstname,
                                    "last_name": lastname,
                                    "payment_status": payment_status,
                                    "platform": "iOS"]
        let credentialData = "\(user):\(password)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        let base64Credentials = credentialData.base64EncodedString()
        
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        
        Alamofire.request(MSavePayment, method: .post, parameters: param, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            
            switch response.result{
            case .success:
                if response.result.value != nil {
                    print(response.result.value as Any)
                    
                    Appsee.addEvent("Purchase", withProperties: [
                        "TransactionID" : transactionid,
                        "TransactionAmount" : orderamt,
                        "PaymentMethodID" : cardtype,
                        "Currency" : "BRL",
                        "tilesUnit" : tilesUnit,
                        "status":payment_status])
                    
                    FBSDKAppEvents.logPurchase(Double(orderamt) ?? 0.0, currency: "BRL", parameters: [
                        "TransactionID" : transactionid,
                        "TransactionAmount" : orderamt,
                        "PaymentMethodID" : cardtype,
                        "tilesUnit" : tilesUnit,
                        "status":payment_status])
                    
                    Analytics.logEvent("Purchase", parameters: [
                        "TransactionID" : transactionid,
                        "TransactionAmount" : orderamt,
                        "PaymentMethodID" : cardtype,
                        "Currency" : "BRL",
                        "tilesUnit" : tilesUnit,
                        "status": payment_status])
                }
            case .failure(let error):
                return
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == CollectionViewPhoto {
            return arySelectUpdateImg.count
        }
        else{
            return aryColor.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = CGFloat()
        if collectionView == CollectionViewPhoto{
            width = self.CollectionViewPhoto.frame.size.height-10//-30
        }
        else{
            width = self.ColorCollectionView.frame.size.height - 10
        }
        let size = CGSize(width: width, height: width)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == CollectionViewPhoto {
            let cell : Review_Cell = CollectionViewPhoto.dequeueReusableCell(withReuseIdentifier: "review_cell", for: indexPath) as! Review_Cell
            
            let userPicDict = arySelectUpdateImg[indexPath.row] as! NSDictionary
            var ImgConvert = UIImage()
            
            if let isAvailable = userPicDict["img"] {
                ImgConvert = isAvailable as! UIImage
            }
            else {
                requestOption.isSynchronous = true
                //                requestOption.resizeMode = .exact
                requestOption.deliveryMode = .highQualityFormat
                requestOption.isNetworkAccessAllowed = true
                
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [userPicDict.value(forKey: "id") as! String], options: .none).firstObject
                imgManager.requestImage(for: asset!, targetSize: CGSize(width: (asset!.pixelWidth)/3, height: (asset!.pixelHeight)/3), contentMode: .aspectFit, options: requestOption, resultHandler: { result, info in
                    ImgConvert = result!
                })
            }
            
            cell.imgUser.image = ImgConvert
            cell.imgFrame.image = UIImage(named: "\(SelectFrame)")
            cell.LblCount.layer.cornerRadius = 5.0
            if let copyimg = userPicDict.value(forKey: "copy") as? Int{
                cell.countOuterview.isHidden = true
                if copyimg > 1 {
                    cell.countOuterview.isHidden = false
                    cell.LblCount.text = "\(copyimg)"
                }
            }
            
            return cell
        }
        else {
            let cell : ColorCell = ColorCollectionView.dequeueReusableCell(withReuseIdentifier: "cellcolor", for: indexPath) as! ColorCell
            cell.btnColor.backgroundColor = (aryColor[indexPath.row] as? UIColor)
            cell.btnColor.SetRediousBtn()
            
            cell.imgBack.isHidden = true
            if indexPath.row == isColorSelectIndex {
                cell.imgBack.isHidden = false
                isColorSelectIndex = indexPath.row
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == CollectionViewPhoto {
            isSelectIndexValue = indexPath.row
            let DictSelect = arySelectUpdateImg.object(at: indexPath.row) as! NSDictionary
            let Cell : Review_Cell = self.CollectionViewPhoto.dequeueReusableCell(withReuseIdentifier: "review_cell", for: indexPath) as! Review_Cell
            
            if let copyimg = DictSelect.value(forKey: "copy") as? Int {
                if copyimg > 1 {
                    Cell.countOuterview.isHidden = false
                    Cell.LblCount.text = "\(copyimg)"
                    self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copies", languageCode: lanCode))"
                }
                else{
                    Cell.countOuterview.isHidden = true
                    self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copy", languageCode: lanCode))"
                }
            }
            AddSubViewtoParentView(parentview: self.view, subview: self.vwEditPopUp!)
        }
        else {
            isColorSelectIndex = indexPath.row
            SelectFrame = aryFrame[indexPath.row] as! String
            ColorCollectionView.reloadData()
            CollectionViewPhoto.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

extension Locale {
    static let br = Locale(identifier: "pt_BR")
    static let us = Locale(identifier: "en_US")
    static let uk = Locale(identifier: "en_UK")
}

extension NumberFormatter {
    convenience init(style: Style, locale: Locale = .current) {
        self.init()
        self.locale = locale
        numberStyle = style
    }
}

extension Formatter {
    static let currency = NumberFormatter(style: .currency)
    static let currencyUS = NumberFormatter(style: .currency, locale: .us)
    static let currencyBR = NumberFormatter(style: .currency, locale: .br)
}

extension Numeric {  
    var currency: String {
        return Formatter.currency.string(for: self) ?? ""
    }
    var currencyUS: String {
        return Formatter.currencyUS.string(for: self) ?? ""
    }
    var currencyBR: String {
        return Formatter.currencyBR.string(for: self) ?? ""
    }
}

