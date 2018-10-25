//
//  ReviewAdjustVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 30/08/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import Alamofire
import CropViewController
import SwiftyToolTip
import Photos
import SWXMLHash
import CoreLocation

class ReviewAdjustVC: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, paymentTokenDelegate, promocodeDiscountDelegate, CropViewControllerDelegate, KACircleCropViewControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var vwSuper: UIView!
    @IBOutlet weak var vwHeader: UIView!
    
    @IBOutlet weak var CollectionViewPhoto: UICollectionView!
    @IBOutlet weak var VwMainFrame: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var vwMadeira: UIView!
    @IBOutlet weak var vwAcrilico: UIView!
    @IBOutlet weak var lblMadeira: UILabel!
    @IBOutlet weak var btnMedeira: UIButton!
    @IBOutlet weak var vwBold: UIView!
    @IBOutlet weak var imgBold: UIImageView!
    @IBOutlet weak var vwZen: UIView!
    @IBOutlet weak var imgZen: UIImageView!
    @IBOutlet weak var imgSelectFrame: UIImageView!
    
    @IBOutlet weak var lblAcrilico: UILabel!
    @IBOutlet weak var btnAcrilico: UIButton!
    
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
    
    
    let locationManager = CLLocationManager()
    
    var arySelectImg = [[String:Any]]()
    var arySelectUpdateImg = NSMutableArray()
    var aryColor = NSMutableArray()
    var aryFrame1 = NSMutableArray()
    var aryFrame2 = NSMutableArray()
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
    var discount : String = ""
    var CPF : String = ""
    
    var imgSelectFrame1 = UIImageView()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.SetUI()
        self.setLocalization()
        arySelectImg = appDelegate.getUserDetails() as! [[String : Any]]
        arySelectUpdateImg = NSMutableArray(array: arySelectImg)
        CollectionViewPhoto.reloadData()
        
        switch UIDevice().type {
        case .iPhoneSE,.iPhone5,.iPhone5S, .iPhone5C:
            self.imgIntroduction.image = UIImage(named: "iphone5")
        case .iPhone6, .iPhone7, .iPhone8, .iPhone6S:
            self.imgIntroduction.image = UIImage(named: "iphone6")
        case .iPhone6plus, .iPhone6Splus, .iPhone7plus, .iPhone8plus:
            self.imgIntroduction.image = UIImage(named: "iphone6+")
        case .iPhoneX, .iPhoneXS:
            self.imgIntroduction.image = UIImage(named: "iphonex")
        default:
            self.imgIntroduction.image = UIImage(named: "iphone6+")
        }
        if defaults.value(forKey: keyIsintroduction) == nil{
            defaults.set(true, forKey: keyIsintroduction)
            AddSubViewtoParentView(parentview: self.view, subview: vwIntroduction)
        }
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        if let PriceDic = defaults.object(forKey: "price") as? NSDictionary {
            if let tempItem = PriceDic.value(forKey: "additional_price") as? Double { additional_price = tempItem }
            if let tempItem = PriceDic.value(forKey: "mimimun_order_quantity") as? Int { mimimun_order_quantity = tempItem }
            if let tempItem = PriceDic.value(forKey: "price_for_moq") as? Double { price_for_moq = tempItem }
        }
        
        var internal_produce_timeindays: Int = 0
        if let ShippingDic = defaults.object(forKey: "shipping") as? NSDictionary {
            if let tempItem = ShippingDic.value(forKey: "internal_produce_timeindays") as? Double { internal_produce_timeindays = Int(tempItem) }
        }
//        print(internal_produce_timeindays)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Calendar.current.date(byAdding: Calendar.Component.day, value: internal_produce_timeindays, to: Date())!)
        
        let dateindate = formatter.date(from: myString)
        formatter.dateFormat = "EEEE, MMMM dd"
        let dateinstring = formatter.string(from: dateindate!)
        
        formatter.dateFormat = "yyyy-MM-dd"
        ShippingDate = formatter.string(from: dateindate!)
        lblShipping.text = "$0.0"
        
        self.lblDeliveryDate.text = "\(LocalizedLanguage(key: "lbl_Deliverd_by", languageCode: lanCode)) " + dateinstring
    }
    
    func setLocalization()
    {
        self.lblHeader.text = LocalizedLanguage(key: "lbl_title_review_adjust", languageCode: lanCode)
        self.lblMadeira.text = LocalizedLanguage(key: "lbl_formats", languageCode: lanCode)
        self.lblAcrilico.text = LocalizedLanguage(key: "lbl_colors", languageCode: lanCode)
        self.lblAddShhippingAdd.text = LocalizedLanguage(key: "lbl_add_shipping_address", languageCode: lanCode)
        self.lblAddCreditCard.text = LocalizedLanguage(key: "lbl_add_credit_card", languageCode: lanCode)
        self.btnAdjust.setTitle(LocalizedLanguage(key: "lbl_adjust_popup", languageCode: lanCode), for: .normal)
        self.btnRemove.setTitle(LocalizedLanguage(key: "lbl_remove_popup", languageCode: lanCode), for: .normal)
        self.btnDismiss.setTitle(LocalizedLanguage(key: "lbl_cancel_popup", languageCode: lanCode), for: .normal)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        self.getPostalCode(lat: locValue.latitude, long: locValue.longitude)
        
        UserDefaults.standard.set(locValue.latitude, forKey: "lat")
        UserDefaults.standard.set(locValue.longitude, forKey: "long")
        UserDefaults.standard.synchronize()
        
        locationManager.stopUpdatingLocation()
    }
    
    func getPostalCode(lat: Double, long: Double) {
        //finding address given the coordinates
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: lat, longitude: long), completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    self.POSTCODE_ORIGIN = pm.postalCode! //zip code
//                    self.CalculateShipping(Total: 0)
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
        })
    }
    
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
        
        if let discountPer = UserDefaults.standard.value(forKey: "discounted_percentage") as? String {
            discount = discountPer
        }
        self.TotalAmount()
    }
    
    func CalculateShipping(Total: Double) {
        
        self.showHUD()
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
        formatter.dateFormat = "EEEE, MMMM dd"
        let dateinstring = formatter.string(from: dateindate!)
        
        self.lblDeliveryDate.text = "\(LocalizedLanguage(key: "lbl_Deliverd_by", languageCode: lanCode)) " + dateinstring
        
        if let TempCEP = (defaults.value(forKey: keydictAddress) as? NSDictionary), ((TempCEP.value(forKey: "cep") as? String) != nil)  {
            CEP = (TempCEP.value(forKey: "cep") as? String)!
        }
        
        let strUrl = "http://ws.correios.com.br/calculador/CalcPrecoPrazo.aspx?nCdEmpresa=&sDsSenha=&sCepOrigem=\(self.POSTCODE_ORIGIN)&sCepDestino=\(CEP)&nVlPeso=\(weight)&nCdFormato=\(String(format: "%g", format))&nVlComprimento=\(length)&nVlAltura=\(height)&nVlLargura=\(width)&sCdMaoPropria=\(selfhand)&nVlValorDeclarado=\(Total)&sCdAvisoRecebimento=\(notice_of_receipt)&nCdServico=\(postoffice_service_type)&nVlDiametro=\(diameter)&StrRetorno=xml&nIndicaCalculo=\(3)"
        
//        let strUrl = "http://ws.correios.com.br/calculador/CalcPrecoPrazo.aspx?nCdEmpresa=&sDsSenha=&sCepOrigem=23080060&sCepDestino=18240-000&nVlPeso=3.6&nCdFormato=1&nVlComprimento=20.5&nVlAltura=9.0&nVlLargura=20.5&sCdMaoPropria=s&nVlValorDeclarado=110.0&sCdAvisoRecebimento=n&nCdServico=41106,40010&nVlDiametro=0&StrRetorno=xml&nIndicaCalculo=3"
        
//        print(strUrl)
        
        Alamofire.request(strUrl).response { (response) in
            self.hideHUD()
            let data = response.data!
            
//            print(response.data!) // if you want to check XML data in debug window.
            let xml = SWXMLHash.parse(data)
//            print(xml)
            self.shippingData = xml["Servicos"].children.min { $0["PrazoEntrega"].element!.text < $1["PrazoEntrega"].element!.text }!
//            print(self.shippingData)
            
            if is_allow_free_frieght == 1 {
                self.ShippingPrice = "FREE"
            }
            else {
                self.ShippingPrice = (self.shippingData["ValorSemAdicionais"].element?.text)!.replacingOccurrences(of: ",", with: ".")
            }
            
            var shippingCharge: Double = 0
            
            if self.ShippingPrice == "" { shippingCharge = 0 } else { shippingCharge = Double(self.ShippingPrice)!}
            if (self.shippingData) != nil {
                let shippingDay = self.shippingData["PrazoEntrega"].element?.text
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let myString = formatter.string(from: Calendar.current.date(byAdding: Calendar.Component.day, value: (Int(shippingDay!)! + internal_produce_timeindays), to: Date())!)
                
                let dateindate = formatter.date(from: myString)
                formatter.dateFormat = "EEEE, MMMM dd"
                let dateinstring = formatter.string(from: dateindate!)
                
                self.lblDeliveryDate.text = "\(LocalizedLanguage(key: "lbl_Deliverd_by", languageCode: lanCode)) " + dateinstring
            }
            self.lblShipping.text = "$\(self.ShippingPrice)"
            self.lblFinalAmount.text = "\(LocalizedLanguage(key: "lbl_total", languageCode: lanCode)) $\(Total + shippingCharge)"
        }
    }
    
    func SetUI()
    {
        aryColor = [getColorIntoHex(Hex: "000000"), getColorIntoHex(Hex: "ffffff"), getColorIntoHex(Hex: "c00000"), getColorIntoHex(Hex: "ffc000"), getColorIntoHex(Hex: "00b069"), getColorIntoHex(Hex: "4472c4")]
        
        aryFrame1 = ["black1","white1","red1","yellow1","green1","blue1"]
        aryFrame2 = ["black2","white2","red2","yellow2","green2","blue2"]
        aryFullProduct = ["35","40","37","36","39","38"]
        arySpacedProduct = ["41","42","43","44","45","46"]
        aryFrame = aryFrame1
        ColorCollectionView.reloadData()
        
        self.vwBold.SetRediousView()
        self.vwZen.SetRediousView()
        self.vwOptionPopUp.SetRediousView()
        self.vwCopies.SetRediousView()
        self.btnmin.SetRediousBtn()
        self.btnmax.SetRediousBtn()
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
        print("removeBtn")
        //        let TotalTiles = Int(CalculateTiles(AryName: self.arySelectUpdateImg))
        var TotalTiles = Int()
        for (index,item) in self.arySelectUpdateImg.enumerated() {
            var copy = (item as! NSDictionary).value(forKey: "copy") as! Int
            if isSelectIndexValue == index {
                copy = 1
            }
            TotalTiles += copy
            print("Final copy: \(TotalTiles), copy: \(copy)")
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
        print("adjustBtn")
        var Dict = self.arySelectImg[isSelectIndexValue]
        requestOption.isSynchronous = true
        requestOption.deliveryMode = .fastFormat
        var ImgConvert = UIImage()
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [Dict["id"] as! String], options: .none).firstObject
        imgManager.requestImage(for: asset!, targetSize: CGSize(width: 400.0, height: 400.0), contentMode: .aspectFit, options: requestOption, resultHandler: { result, info in
            ImgConvert = result!
            //            print(asset?.localIdentifier)
        })
        
        //        let image: UIImage = Dict["img"] as! UIImage
        
        //        let cropViewController = CropViewController(image: image)
        //        cropViewController.delegate = self
        //        cropViewController.aspectRatioPreset = .presetSquare
        //        cropViewController.rotateButtonsHidden = true
        //
        //        cropViewController.aspectRatioLockEnabled = true
        //        cropViewController.resetAspectRatioEnabled = false
        //        cropViewController.rotateClockwiseButtonHidden = true
        //        present(cropViewController, animated: true, completion: nil)
        
        let circleCropController = KACircleCropViewController(withImage: ImgConvert)
        circleCropController.delegate = self
        
        self.present(circleCropController, animated: false, completion: nil)
        
    }
    
    func circleCropDidCancel() {
        //Basic dismiss
        dismiss(animated: false, completion: nil)
    }
    
    func circleCropDidCropImage(_ image: UIImage) {
        let Imgconvert = self.ResizeImage(image: image, targetSize: CGSize(width: 700.0, height: 700.0))
//        print(image)
        var Dict = self.arySelectUpdateImg[isSelectIndexValue] as! [String:Any]
        Dict.updateValue(Imgconvert, forKey: "img")
        self.arySelectUpdateImg.replaceObject(at: isSelectIndexValue, with: Dict)
        CollectionViewPhoto.reloadData()
        self.vwEditPopUp.removeFromSuperview()
        dismiss(animated: false, completion: nil)
    }
    
    /*  func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int)
     {
     //        let indexPath = IndexPath(item: isSelectIndexValue, section: 0)
     //        let Cell : Review_Cell = self.CollectionViewPhoto.cellForItem(at: indexPath) as! Review_Cell
     //        Cell.imgUser.image = image
     
     var Dict = self.arySelectUpdateImg[isSelectIndexValue] as! [String:Any]
     Dict.updateValue(image, forKey: "img")
     self.arySelectUpdateImg.replaceObject(at: isSelectIndexValue, with: Dict)
     CollectionViewPhoto.reloadData()
     self.vwEditPopUp.removeFromSuperview()
     cropViewController.dismiss(animated: false, completion: nil)
     
     }*/
    
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
                            Cell.LblCount.isHidden = false
                            Cell.LblCount.text = "\(copyimg)"
                            self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copies", languageCode: lanCode))"
                        }
                        else{
                            Cell.LblCount.isHidden = true
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
                        //                    showAlert(titleStr: "Select At least \(mimimun_order_quantity) photos", msg: "")
                    }
                    else {
                        if copyimg > 1 {
                            copyimg = copyimg - 1
                            if copyimg > 1 {
                                Cell.LblCount.isHidden = false
                                Cell.LblCount.text = "\(copyimg)"
                                self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copies", languageCode: lanCode))"
                            }
                            else{
                                Cell.LblCount.isHidden = true
                                Cell.LblCount.text = "\(copyimg)"
                                self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copy", languageCode: lanCode))"
                            }
                        }
                        else{
                            Cell.LblCount.isHidden = true
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
            
            self.arySelectImg[self.self.isSelectIndexValue] = Dict
            self.arySelectUpdateImg.replaceObject(at: self.isSelectIndexValue, with: Dict)
            let userdict = NSKeyedArchiver.archivedData(withRootObject: self.arySelectImg)
            defaults.setValue(userdict, forKey: keyarymain)
            defaults.synchronize()
        }
    }
    
    @IBAction func Click_helpBtn(_ sender: UIButton) {
        AddSubViewtoParentView(parentview: self.view, subview: self.vwIntroduction!)
    }
    
    @IBAction func Click_MadeiraBtn(_ sender: UIButton) {
        btnMedeira.addToolTip(description: "BOLD:- \n jotagonist of the story in the mars volta albujm, De-loused ink the atojkrium. Akfyuter overdosing on morphine, he enters a dreaem world where he put througha series of trials bt the tremulants, enture from hyis own minud that inspire his art.Animated popover, great for subtle UI tips and onboarding", gesture: .doubleTap, isEnabled: true)
    }
    
    @IBAction func Click_AcrilicoBtn(_ sender: UIButton) {
        btnAcrilico.addToolTip(description: "CLEAN:- \n jotagonist of the story in the mars volta albujm, De-loused ink the atojkrium. Akfyuter overdosing on morphine, he enters a dreaem world where he put througha series of trials bt the tremulants, enture from hyis own minud that inspire his art.Animated popover, great for subtle UI tips and onboarding", gesture: .doubleTap, isEnabled: true)
    }
    
    @IBAction func Click_addCreditCardBtn(_ sender: UIButton) {
        let addCreditVC = storyboard?.instantiateViewController(withIdentifier: "AddCreditCardVC") as! AddCreditCardVC
        addCreditVC.delegate = self
        self.navigationController?.pushViewController(addCreditVC, animated: true)
    }
    
    @IBAction func Click_addShippingAdd(_ sender: UIButton) {
        
        let AddressVC = storyboard?.instantiateViewController(withIdentifier: "AddAddressVC") as! AddAddressVC
        self.navigationController?.pushViewController(AddressVC, animated: true)
    }
    
    @IBAction func Click_AddPromocodeBtn(_ sender: UIButton) {
        let AddPromoVC = storyboard?.instantiateViewController(withIdentifier: "AddPromoCodeVC") as! AddPromoCodeVC
        AddPromoVC.delegate = self
        self.navigationController?.pushViewController(AddPromoVC, animated: true)
    }
    
    @IBAction func Click_BoldFilter(_ sender: UIButton) {
        imgSelectFrame.removeFromSuperview()
        imgSelectFrame.frame = sender.frame
        
        if sender.tag == 101{
            aryFrame = aryFrame1
            SelectFrame = aryFrame[isColorSelectIndex] as! String
            vwBold.addSubview(imgSelectFrame)
            //            self.vwBold.bringSubview(toFront: lblBold)
        }
        else if sender.tag == 102{
            aryFrame = aryFrame2
            vwZen.addSubview(imgSelectFrame)
            SelectFrame = aryFrame[isColorSelectIndex] as! String
            //            self.vwZen.bringSubview(toFront: lblZen)
        }
        /*else if sender.tag == 103{
         vwClean.addSubview(imgSelectFrame)
         self.vwClean.bringSubview(toFront: lblClean)
         }else if sender.tag == 104{
         vwNoir.addSubview(imgSelectFrame)
         self.vwNoir.bringSubview(toFront: lblNoir)
         }*/
        
        indexFilter = sender.tag
        CollectionViewPhoto.reloadData()
    }
    
    func paymentToken(token: String, paymentid: String, cpf: String) {
        self.TokenId = token
        self.paymentId = paymentid
        self.CPF = cpf
    }
    
    func promocodeDicount(dict: NSDictionary, promoCode: String) {
        self.promoCode = promoCode
        if let discountPer = dict.value(forKey: "discounted_percentage") as? String {
            discount = discountPer
            self.TotalAmount()
        }
    }
    
    func TotalAmount()
    {
        let PromoCode: String = !promoCode.isEmpty ? "(\(promoCode))" : ""
        let TotalTiles = CalculateTiles(AryName: self.arySelectUpdateImg)
        let minimumQuantity: Double = Double(mimimun_order_quantity)
        
        let minimumOrderAmount: Double = price_for_moq
        let additionalOrderAmount: Double = (TotalTiles - minimumQuantity) * additional_price
        GrandTotalAmount = minimumOrderAmount + additionalOrderAmount
        
        let Discount: Double = !discount.isEmpty ? ((GrandTotalAmount * Double(discount)!) / 100) : 0
        
        self.lblTiles.text = "\(mimimun_order_quantity) \(LocalizedLanguage(key: "lbl_tiles_for", languageCode: lanCode)) $\(String(format: "%g", price_for_moq))"
        self.lblTotalTilesPrice.text = "$\(String(format: "%g", price_for_moq))"
        self.lblMoreTiles.text = (TotalTiles - minimumQuantity) != 0 ? "\(String(format: "%g", TotalTiles - minimumQuantity)) \(LocalizedLanguage(key: "lbl_more_tiles", languageCode: lanCode)), $\(String(format: "%g", additional_price)) \(LocalizedLanguage(key: "lbl_each", languageCode: lanCode))" : ""
        self.lblTotalMoreTilesPrice.text = (TotalTiles - minimumQuantity) != 0 ? "$\(String(format: "%g", (TotalTiles - minimumQuantity) * additional_price))" : ""
        self.lblPromoCode.text = PromoCode
        self.lblDicountPrice.text = Discount != 0 ? "-$\(Discount)" : ""
        
        if defaults.value(forKey: keydictAddress) != nil {
            if Reachability.isConnectedToNetwork() {
                self.CalculateShipping(Total: GrandTotalAmount - Discount)
            }
            else {
                showAlert(titleStr: alertNetwork, msg: "")
            }
        }
        else {
            self.lblFinalAmount.text = "\(LocalizedLanguage(key: "lbl_total", languageCode: lanCode)) $\(GrandTotalAmount - Discount)"
        }
    }
    
    func CalculateTiles(AryName : NSMutableArray) -> Double {
        var finalTilesCnt = Int()
        for item in AryName {
            let copy = (item as! NSDictionary).value(forKey: "copy") as! Int
            finalTilesCnt = finalTilesCnt + copy
            print("Final copy: \(finalTilesCnt), copy: \(copy)")
        }
        return Double(finalTilesCnt)
    }
    
    func shakeAnimation(vwName: UIView)
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: vwName.center.x - 10, y: vwName.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: vwName.center.x + 10, y: vwName.center.y))
        
        vwName.layer.add(animation, forKey: "position")
    }
    
    func AddSubViewtoParentView(parentview: UIView! , subview: UIView!)
    {
        subview.translatesAutoresizingMaskIntoConstraints = false
        parentview.addSubview(subview);
        parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: parentview, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: parentview, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: parentview, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: parentview, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
        parentview.layoutIfNeeded()
    }
    
    @IBAction func Click_ConfirmOrder(_ sender: UIButton) {
        let Cnt = Int(CalculateTiles(AryName: arySelectUpdateImg))
        if Cnt >= mimimun_order_quantity {
            if defaults.value(forKey: keydictAddress) == nil{
                showAlert(titleStr: LocalizedLanguage(key: "alert_add_shipping_address", languageCode: lanCode), msg: "")
            }
            else {
                if self.paymentId.isEmpty {
                    showAlert(titleStr: LocalizedLanguage(key: "alert_add_credit_card_details", languageCode: lanCode), msg: "")
                }
                else {
                    if self.paymentId == "bolbradesco" || !self.TokenId.isEmpty {
                        self.showHUD()
                        var ImgCnt = 0
//                        print(arySelectUpdateImg.count)
                        if arySelectUpdateImg.count <= 3 {
                            ImgCnt = arySelectUpdateImg.count
                        }
                        else {
                            ImgCnt = 3
                        }
                        
                        let param : NSMutableDictionary = NSMutableDictionary()
                        for i in 0..<ImgCnt{
                            
                            let dictImg = arySelectUpdateImg[i] as! NSDictionary
                            var selectimg = UIImage()
                            if let isAvailable = dictImg["img"] {
                                selectimg = isAvailable as! UIImage
                            }
                            else{
                                requestOption.isSynchronous = true
                                requestOption.deliveryMode = .fastFormat
                                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [dictImg.value(forKey: "id") as! String], options: .none).firstObject
                                imgManager.requestImage(for: asset!, targetSize: CGSize(width: 400.0, height: 400.0), contentMode: .aspectFit, options: requestOption, resultHandler: { result, info in
                                    selectimg = self.RBSquareImageTo(image: result!, size: CGSize(width: 700.0, height: 700.0))
                                })
                            }
                            var productId = String()
                            if indexFilter == 101{
                                productId = "\(aryFullProduct.object(at: isColorSelectIndex) as! String)"
                            }
                            else{
                                productId = "\(arySpacedProduct.object(at: isColorSelectIndex) as! String)"
                            }
//                            print(selectimg.size)
//                            print(productId)
                            let base64 = convertImageToBase64(image: selectimg)
                            
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
                        
                        var shippingCharge: Double = 0
                        if self.ShippingPrice == "" || self.ShippingPrice == "FREE" {
                            shippingCharge = 0
                        } else {
                            shippingCharge = Double(self.ShippingPrice)!
                        }
                        
                        param.setValue(firstname, forKey: "first_name")
                        param.setValue(lastname, forKey: "last_name")
                        
                        param.setValue(1, forKey: "user_id")
                        param.setValue(GrandTotalAmount + shippingCharge, forKey: "total_tiles_price")
                        param.setValue(dictAdd.value(forKey: "email") as! String, forKey: "email")
                        param.setValue(StreetAddandNo, forKey: "street_address")
                        param.setValue(defaults.value(forKey: keycpfno) as! String, forKey: "cpf")
                        param.setValue(dictAdd.value(forKey: "cep") as! String, forKey: "postal_code")
                        param.setValue(dictAdd.value(forKey: "phoneno") as! String, forKey: "phone_number")
                        param.setValue(dictAdd.value(forKey: "city") as! String, forKey: "city")
                        param.setValue(dictAdd.value(forKey: "state") as! String, forKey: "state")
                        param.setValue(self.promoCode, forKey: "promo_code")
                        param.setValue("\(ShippingDate)", forKey: "delivery_date")
                        param.setValue("\(shippingCharge)", forKey: "shipping_price")
//                        print(param)
                        if Reachability.isConnectedToNetwork(){
                            ApiPostTilesinfo(dict: param)
                        }
                        else{
                            showAlert(titleStr: alertNetwork, msg: "")
                            self.hideHUD()
                        }
                    }
                    else {
                        showAlert(titleStr: LocalizedLanguage(key: "alert_add_credit_card_details", languageCode: lanCode), msg: "")
                    }
                }
            }
        }
        else{
            showAlert(titleStr: "\(mimimun_order_quantity - Cnt) \(LocalizedLanguage(key: "alert_more_tiles_needed", languageCode: lanCode))", msg: LocalizedLanguage(key: "alert_brickart", languageCode: lanCode))
        }
        
    }
    
    func ApiPostTilesinfo(dict : NSDictionary)
    {
        let credentialData = "\(user):\(password)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        let base64Credentials = credentialData.base64EncodedString()
        
        let headers = [
            "Authorization": "Basic \(base64Credentials)"]
        let param = dict as! [String:Any]
//        print(param)
        Alamofire.request(Msendtilesinfo, method: .post, parameters: param, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            
            switch response.result{
            case .success:
                if response.result.value != nil{
                    let ResponseDict = response.result.value as! NSDictionary
                    if let status = ResponseDict.value(forKey: "status") as? Bool{
                        if status == true{
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
                            
                        }else{
                            self.hideHUD()
                            self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                            
                        }
                    }else{
                        self.hideHUD()
                        self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                    }
//                    print(ResponseDict)
                }
            case .failure(let error):
                print(error)
                self.hideHUD()
                self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                return
            }
        }
    }
    
    func ApiUpdateOrderTiles(order_id: String)
    {
        var imgCnt = 0
        if (arySelectUpdateImg.count)-3 <= imgCount{
            imgCnt = arySelectUpdateImg.count - imgCount
            souldCallPayment = true
        }else{
            imgCnt = 3
        }
        let param : NSMutableDictionary = NSMutableDictionary()
        for imgCount in imgCount..<imgCount + imgCnt{
            
            let dictImg = arySelectUpdateImg[imgCount] as! NSDictionary
            var selectimg = UIImage()
            if let isAvailable = dictImg["img"]{
                selectimg = isAvailable as! UIImage
            }else{
                requestOption.isSynchronous = true
                requestOption.deliveryMode = .fastFormat
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [dictImg.value(forKey: "id") as! String], options: .none).firstObject
                imgManager.requestImage(for: asset!, targetSize: CGSize(width: 400.0, height: 400.0), contentMode: .aspectFit, options: requestOption, resultHandler: { result, info in
                    selectimg = self.RBSquareImageTo(image: result!, size: CGSize(width: 700.0, height: 700.0))
                })
            }
            
            var productId = String()
            if indexFilter == 101{
                productId = "\(aryFullProduct.object(at: isColorSelectIndex) as! String)"
            }
            else{
                productId = "\(arySpacedProduct.object(at: isColorSelectIndex) as! String)"
            }
            
            let base64 = convertImageToBase64(image: selectimg)
            let copy = dictImg.value(forKey: "copy") as! Int
            
            if imgCount < mimimun_order_quantity {
                param.setValue(price_for_moq / Double(mimimun_order_quantity), forKey: "tiles_details[\(imgCount)][price]")
            }
            else {
                param.setValue(additional_price, forKey: "tiles_details[\(imgCount)][price]")
            }
            
            param.setValue(productId, forKey: "tiles_details[\(imgCount)][product_id]")
            param.setValue("set", forKey: "tiles_details[\(imgCount)][product_type]")
            param.setValue("25", forKey: "tiles_details[\(imgCount)][product_size]")
            param.setValue(base64, forKey: "tiles_details[\(imgCount)][image_base64]")
            param.setValue(copy, forKey: "tiles_details[\(imgCount)][tiles_copy]")
        }
        param.setValue(1, forKey: "user_id")
        param.setValue(order_id, forKey: "order_id")
        //        print(param)
        if Reachability.isConnectedToNetwork(){
            ApiPostUpdateOrderTiles(dict: param)
        }else{
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
        
        //        let manager = Alamofire.SessionManager.default
        //        manager.session.configuration.timeoutIntervalForRequest = 120
        //        manager.request(MupdateOrderTiles, method: .post, parameters: param, encoding: URLEncoding.default, headers: headers)
        
        Alamofire.request(MupdateOrderTiles, method: .post, parameters: param, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            
            switch response.result{
            case .success:
                if response.result.value != nil{
                    let ResponseDict = response.result.value as! NSDictionary
                    if let status = ResponseDict.value(forKey: "status") as? Bool{
                        if status == true{
                            let data = ResponseDict.value(forKey: "data") as! NSDictionary
                            DispatchQueue.main.async(execute: {
                                self.imgCount += 3
                                if (self.souldCallPayment == true || self.imgCount == self.arySelectUpdateImg.count){
                                    self.ApiPostPayment(dict: data)
                                }
                                else{
                                    if let orderid = ((data.value(forKey: "order") as? NSArray)?.object(at: 0) as! NSDictionary).value(forKey: "order_id") as? String
                                    {
                                        DispatchQueue.main.async(execute: {
                                            self.ApiUpdateOrderTiles(order_id : orderid)
                                        })
                                    }
                                }
                            })
                        }else{
                            self.hideHUD()
                            self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                        }
                    }else{
                        self.hideHUD()
                        self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                    }
                    //                    print(ResponseDict)
                }
                
            case .failure(let error):
                print(error)
                self.hideHUD()
                self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                return
            }
        }
    }
    
    func ApiPostPayment(dict : NSDictionary)
    {
        let AryOrder  = dict.value(forKey: "order") as! NSArray
        let TempDict = NSMutableDictionary()
        if self.paymentId == "bolbradesco" {
            TempDict.setValue(GrandTotalAmount, forKey: "transaction_amount")
            TempDict.setValue("this is test", forKey: "description")
            TempDict.setValue(self.paymentId, forKey: "payment_method_id")
            
            let payerDict = NSMutableDictionary()
            payerDict.setValue((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "email") as! String, forKey: "email")
            
            var firstname: String = ""
            var lastname: String = ""
            let fullname = ((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "fullname") as! String).components(separatedBy: " ")
            if fullname.count > 1 {
                firstname = fullname[0]
                lastname = fullname[1]
            }
            else {
                firstname = fullname[0]
                lastname = ""
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
            TempDict.setValue(GrandTotalAmount, forKey: "transaction_amount")
            TempDict.setValue(self.TokenId, forKey: "token")
            TempDict.setValue("this is test", forKey: "description")
            TempDict.setValue(self.paymentId, forKey: "payment_method_id")
            TempDict.setValue(1, forKey: "installments")
            let payerDict = NSMutableDictionary()
            payerDict.setValue((defaults.value(forKey: keydictAddress) as! NSDictionary).value(forKey: "email") as! String, forKey: "email")
            TempDict.setValue(payerDict, forKey: "payer")
            TempDict.setValue("\(Date().millisecondsSince1970)", forKey: "external_reference")
        }
        
//        print(TempDict)
        Alamofire.request(Mpayments, method: .post, parameters: (TempDict as! [String:Any]), encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            self.hideHUD()
            if response.error != nil{
                self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                return
            }
            
            if response.result.value != nil{
                let ResponseDict = response.result.value as! NSDictionary
//                print(ResponseDict)
                if let status = ResponseDict.value(forKey: "status") as? String{
                    if status == "approved" || status == "pending"
                    {
                        var firstname = String()
                        var lastname = String()
                        var email = String()
                        var cardTypes = String()
                        var expirymonth = Int()
                        var expiryyear = Int()
                        
                        if let fname = (ResponseDict.value(forKey: "payer") as? NSDictionary)?.value(forKey: "first_name") as? String{
                            firstname = fname
                        }
                        
                        if let lname = (ResponseDict.value(forKey: "payer") as? NSDictionary)?.value(forKey: "last_name") as? String{
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
                        
                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "OrderCompleteVC") as! OrderCompleteVC
                        VC.orderid = (AryOrder[0] as! NSDictionary).value(forKey: "order_id") as! String
                        VC.orderamt = self.lblFinalAmount.text!.replacingOccurrences(of: "\(LocalizedLanguage(key: "lbl_total", languageCode: lanCode)) $", with: "")
                        VC.transactionid = ResponseDict.value(forKey: "id") as! NSNumber
                        VC.cardtype = cardTypes
                        VC.cardexpiry = "\(expirymonth)/\(expiryyear)"
                        VC.firstname = firstname
                        VC.lastname = lastname
                        VC.email = email
                        VC.DictResponse =  NSMutableDictionary(dictionary: ResponseDict)
                        self.navigationController?.pushViewController(VC, animated: true)
                    }
                    else{
                        self.hideHUD()
                        self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
//                        print(ResponseDict)
                    }
                }
                else{
                    self.hideHUD()
                    self.showAlert(titleStr: "\(ResponseDict.value(forKey: "message") as! String)", msg: "")
//                    print(ResponseDict)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == CollectionViewPhoto{
            return arySelectUpdateImg.count
        }
        else{
            return aryColor.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = CGFloat()
        if collectionView == CollectionViewPhoto{
            width = self.CollectionViewPhoto.frame.size.height - 30
        }
        else{
            width = self.ColorCollectionView.frame.size.height - 10
        }
        let size = CGSize(width: width, height: width)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == CollectionViewPhoto{
            let cell : Review_Cell = CollectionViewPhoto.dequeueReusableCell(withReuseIdentifier: "review_cell", for: indexPath) as! Review_Cell
            let userPicDict = arySelectUpdateImg[indexPath.row] as! NSDictionary
            var ImgConvert = UIImage()
            
            if let isAvailable = userPicDict["img"]{
                ImgConvert = isAvailable as! UIImage
            }else{
                requestOption.isSynchronous = true
                requestOption.deliveryMode = .fastFormat
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [userPicDict.value(forKey: "id") as! String], options: .none).firstObject
                imgManager.requestImage(for: asset!, targetSize: CGSize(width: 200.0, height: 200.0), contentMode: .aspectFit, options: requestOption, resultHandler: { result, info in
                    ImgConvert = result!
                })
            }
            cell.imgUser.image = ImgConvert
            cell.imgFrame.image = UIImage(named: "\(SelectFrame)")
            cell.LblCount.layer.cornerRadius = 5.0
            if let copyimg = userPicDict.value(forKey: "copy") as? Int{
                cell.LblCount.isHidden = true
                if copyimg > 1{
                    cell.LblCount.isHidden = false
                    cell.LblCount.text = "\(copyimg)"
                }
            }
            return cell
        }
        else{
            let cell : ColorCell = ColorCollectionView.dequeueReusableCell(withReuseIdentifier: "cellcolor", for: indexPath) as! ColorCell
            cell.btnColor.backgroundColor = (aryColor[indexPath.row] as? UIColor)
            cell.btnColor.SetRediousBtn()
            
            cell.imgBack.isHidden = true
            if indexPath.row == isColorSelectIndex
            {
                cell.imgBack.isHidden = false
                isColorSelectIndex = indexPath.row
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == CollectionViewPhoto{
            isSelectIndexValue = indexPath.row
            let DictSelect = arySelectUpdateImg.object(at: indexPath.row) as! NSDictionary
            let Cell : Review_Cell = self.CollectionViewPhoto.dequeueReusableCell(withReuseIdentifier: "review_cell", for: indexPath) as! Review_Cell
            
            if let copyimg = DictSelect.value(forKey: "copy") as? Int{
                if copyimg > 1{
                    Cell.LblCount.isHidden = false
                    Cell.LblCount.text = "\(copyimg)"
                    self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copies", languageCode: lanCode))"
                }
                else{
                    Cell.LblCount.isHidden = true
                    self.lblCopies.text = "\(copyimg) \(LocalizedLanguage(key: "lbl_copy", languageCode: lanCode))"
                }
            }
            AddSubViewtoParentView(parentview: self.view, subview: self.vwEditPopUp!)
        }
        else{
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
        let templateImage = self.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
