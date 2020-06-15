//
//  ViewController.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 27/08/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import Photos
import CarbonKit
import Alamofire
import PhotosUI
var MainAry = NSMutableArray()
var AryCategoryList = [String]()
var SelectedTab: Int = 0

//IMAGE SELECT VC
class ViewController: BaseViewController, CarbonTabSwipeNavigationDelegate {
    
    var allPhotos: PHFetchResult<PHAsset>!
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    var userCollections: PHFetchResult<PHCollection>!
    var fetchResult: PHFetchResult<PHAsset>!
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    //MARK:- Outlets
    @IBOutlet weak var lblTitles: UILabel!
    @IBOutlet weak var vwSuper: UIView!
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var VwTabView: UIView!
    @IBOutlet weak var lblSelectPhotos: UILabel!
    @IBOutlet weak var btnReviewTiles: UIButton!
    @IBOutlet weak var lblAdditional: UILabel!
    
    //MARK:- Variable Decleration
    var carbonTabSwipeNavigation = CarbonTabSwipeNavigation()
    
    var appDelegate : AppDelegate = AppDelegate()
    var arySelected = [[String:Any]]()
    var ArySelectAdd = NSMutableArray()
    
    var additional_price: Double = 0
    var mimimun_order_quantity: Int = 0
    var price_for_moq: Double = 0
    
    var isShippingSet:((Bool)->())?
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        /* getFavouritesImages()
         smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
         PHPhotoLibrary.shared().register(self)
         let collection: PHCollection
         collection = smartAlbums.object(at: 0)
         guard let assetCollection = collection as? PHAssetCollection
         else { fatalError("Expected an asset collection.") }
         fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
         //destination.assetCollection = assetCollection
         
         if fetchResult != nil {
         let allPhotosOptions = PHFetchOptions()
         allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
         fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
         let asset = fetchResult.object(at: 0)
         print(fetchResult.object(at: 0).localIdentifier)
         /*imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
         let imageview = UIImageView()
         imageview.image = image
         //                if cell.representedAssetIdentifier == asset.localIdentifier {
         //                    cell.thumbnailImage = image
         //                }
         })*/
         }
         
         
         */
        
        
        self.setDefault()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    //MARK:- Private Method
    func setDefault() {
        if let PriceDic = defaults.object(forKey: "price") as? NSDictionary {
            if let tempItem = PriceDic.value(forKey: "additional_price") as? Double
            { additional_price = tempItem }
            if let tempItem = PriceDic.value(forKey: "mimimun_order_quantity") as? Int { mimimun_order_quantity = tempItem }
            if let tempItem = PriceDic.value(forKey: "price_for_moq") as? Double { price_for_moq = tempItem }
        }
        
        self.checkPhotoLibraryPermission()
        self.setLocalization()
        self.getPrice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        arySelected = appDelegate.getUserDetails() as! [[String : Any]]
        print(arySelected)
        
        if arySelected.count < mimimun_order_quantity {
            self.lblSelectPhotos.text = LocalizedLanguage(key: "pick_more", languageCode: lanCode) + "\((mimimun_order_quantity - arySelected.count))"
            self.lblAdditional.text = "\(mimimun_order_quantity)" + LocalizedLanguage(key: "moq_tile", languageCode: lanCode) + price_for_moq.currencyBR
        }
        else {
            self.lblSelectPhotos.text = "\(arySelected.count)" + LocalizedLanguage(key: "tiles_selected", languageCode: lanCode)
            
            self.lblAdditional.text = LocalizedLanguage(key: "addtional_tile", languageCode: lanCode) + additional_price.currencyBR
        }
    }
    
    @objc func willResignActive(_ notification: Notification) {
        let userdict = NSKeyedArchiver.archivedData(withRootObject: arySelected)
        defaults.setValue(userdict, forKey: keyarymain)
        defaults.synchronize()
    }
    
    func setLocalization() {
        self.lblTitles.text = LocalizedLanguage(key: "lbl_pick_photo", languageCode: lanCode).uppercased()
        self.btnReviewTiles.setTitle("  \(LocalizedLanguage(key: "btn_review_tiles", languageCode: lanCode))", for: .normal)
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
                    
                    if let tempItem = PriceDic.value(forKey: "additional_price") as? Double { self.additional_price = tempItem }
                    if let tempItem = PriceDic.value(forKey: "mimimun_order_quantity") as? Int { self.mimimun_order_quantity = tempItem }
                    if let tempItem = PriceDic.value(forKey: "price_for_moq") as? Double { self.price_for_moq = tempItem }
                }
                
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
            }
            else {
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
            }
        }
    }
    
    func setCountTiles() {
        
        var arySelectTiles = [[String:Any]]()
        var Count : Int = 0
        for (index,item) in MainAry.enumerated() {
            
            let aryItem = (item as! NSDictionary).value(forKey: "\(AryCategoryList[index])") as! NSArray
            for item2 in aryItem {
                if (item2 as! NSDictionary).value(forKey: "is_select") as! Bool
                {
                    Count += 1
                    arySelectTiles.append(item2 as! [String : Any])
                }
            }
        }
        
        self.arySelected = arySelectTiles
        if Count < mimimun_order_quantity {
            self.lblSelectPhotos.text = LocalizedLanguage(key: "pick_more", languageCode: lanCode) + "\((mimimun_order_quantity - Count))"
            self.lblAdditional.text = "\(mimimun_order_quantity)" + LocalizedLanguage(key: "moq_tile", languageCode: lanCode) + price_for_moq.currencyBR
        }
        else {
            self.lblSelectPhotos.text = "\(Count)" + LocalizedLanguage(key: "tiles_selected", languageCode: lanCode)
            
            self.lblAdditional.text = LocalizedLanguage(key: "addtional_tile", languageCode: lanCode) + additional_price.currencyBR
        }
    }
    
    func checkPhotoLibraryPermission() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    self.GetPhotos()
                } else {
                    let alert = UIAlertController(title: "Photos Access Denied", message: "App needs access to photos library.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else if photos == .authorized {
            self.GetPhotos()
        }
    }
    
    func GetPhotos() {
        DispatchQueue.main.async {
            ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
            self.GetAllPhotos()
            self.GetWhatsAppPic()
            self.getFavouritesImages()
            ApiUtillity.sharedInstance.dismissSVProgressHUD()
            self.Settabbar()
            /* DispatchQueue.main.async {
             self.GetWhatsAppPic()
             self.getFavouritesImages()
             ApiUtillity.sharedInstance.dismissSVProgressHUD()
             self.Settabbar()
             }*/
        }
    }
    
    func Settabbar() {
        if AryCategoryList.count > 0 {
            carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: AryCategoryList, delegate: self)
            carbonTabSwipeNavigation.insert(intoRootViewController: self, andTargetView:self.VwTabView)
            carbonTabSwipeNavigation.toolbar.isTranslucent = false
            carbonTabSwipeNavigation.setIndicatorColor(UIColor.white)
            carbonTabSwipeNavigation.setTabExtraWidth(30)
            carbonTabSwipeNavigation.setSelectedColor(UIColor(hexString: color.themeColor))
            carbonTabSwipeNavigation.setNormalColor(UIColor.black, font: UIFont.boldSystemFont(ofSize: 14))
            carbonTabSwipeNavigation.carbonTabSwipeScrollView.isScrollEnabled = true
            //carbonTabSwipeNavigation.
            // carbonTabSwipeNavigation.toolbar.setBackgroundImage(#imageLiteral(resourceName: "ic_navbar"), forToolbarPosition: .any, barMetrics: .default)
        }
    }
    
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        let vc:ImagesVC = self.storyboard?.instantiateViewController(withIdentifier: "ImagesVC") as! ImagesVC
        vc.SelectedTab = Int(index)
        vc.vc = self
        return vc
    }
    
    func GetAllPhotos() {
        
        MainAry.removeAllObjects()
        AryCategoryList.removeAll()
        
        let requestOption = PHImageRequestOptions()
        requestOption.isSynchronous = true
        requestOption.deliveryMode = .fastFormat
        
        //        let fetchOptions = PHFetchOptions()
        //        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: nil)
        {
            let TmpDic = NSMutableDictionary()
            
            let tempAry = NSMutableArray()
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count {
                    let tempDict = NSMutableDictionary()
                    
                    if self.arySelected.count != 0 {
                        var isCheck = Bool()
                        var copyCount = Int()
                        for j in 0..<self.arySelected.count{
                            let id = (self.arySelected[j] as NSDictionary).value(forKey: "id") as! String
                            let selectIndex = (self.arySelected[j] as NSDictionary).value(forKey: "SelectIndex") as! Int
                            
                            let count = (self.arySelected[j] as NSDictionary).value(forKey: "copy") as! Int
                            if id == fetchResult.object(at: i).localIdentifier && selectIndex == 0{
                                copyCount = count
                                isCheck = true
                                break;
                            } else {
                                isCheck = false
                            }
                        }
                        if isCheck {
                            tempDict.setValue(true, forKey: "is_select")
                            tempDict.setValue(0, forKey: "SelectIndex")
                            tempDict.setValue(copyCount, forKey: "copy")
                            tempDict.setValue("\(fetchResult.object(at: i).localIdentifier)", forKey: "id")
                        }
                        else {
                            tempDict.setValue(false, forKey: "is_select")
                            tempDict.setValue(0, forKey: "SelectIndex")
                            tempDict.setValue(1, forKey: "copy")
                            tempDict.setValue("\(fetchResult.object(at: i).localIdentifier)", forKey: "id")
                        }
                    }
                    else{
                        tempDict.setValue(false, forKey: "is_select")
                        tempDict.setValue(0, forKey: "SelectIndex")
                        tempDict.setValue(1, forKey: "copy")
                        tempDict.setValue("\(fetchResult.object(at: i).localIdentifier)", forKey: "id")
                    }
                    tempAry.add(tempDict)
                }
            }
            TmpDic.setValue((tempAry.reversed() as NSArray).mutableCopy() as! NSMutableArray, forKey: "All Photos")
            AryCategoryList.append("All Photos")
            MainAry.add(TmpDic)
        }
    }
    
    func getFavouritesImages()
    {
        // let albumList = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        let albumList = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        
        albumList.enumerateObjects { (coll, index, _) in
            if let result: PHFetchResult = PHAsset.fetchAssets(in: coll, options: nil) {
                let TmpDic = NSMutableDictionary()
                print(coll.localizedTitle)
                
                
                if coll.localizedTitle! == "Favorites" || coll.localizedTitle! == "Favoritos"
                {
                    let tempAry = NSMutableArray()
                    if result.count > 0 {
                        for i in 0..<result.count{
                            let asset = result.object(at: i)
                            let tempDict = NSMutableDictionary()
                            if self.arySelected.count != 0 {
                                var isCheck = Bool()
                                var copyCount = Int()
                                for j in 0..<self.arySelected.count{
                                    let id = (self.arySelected[j] as NSDictionary).value(forKey: "id") as! String
                                    let selectIndex = (self.arySelected[j] as NSDictionary).value(forKey: "SelectIndex") as! Int
                                    let count = (self.arySelected[j] as NSDictionary).value(forKey: "copy") as! Int
                                    if id == result.object(at: i).localIdentifier && selectIndex == 1 {
                                        isCheck = true
                                        copyCount = count
                                        break;
                                    }
                                    else {
                                        isCheck = false
                                    }
                                }
                                if isCheck {
                                    tempDict.setValue(true, forKey: "is_select")
                                    tempDict.setValue(1, forKey: "SelectIndex")
                                    tempDict.setValue(copyCount, forKey: "copy")
                                    tempDict.setValue("\(asset.localIdentifier)", forKey: "id")
                                }
                                else {
                                    tempDict.setValue(false, forKey: "is_select")
                                    tempDict.setValue(1, forKey: "SelectIndex")
                                    tempDict.setValue(1, forKey: "copy")
                                    tempDict.setValue("\(asset.localIdentifier)", forKey: "id")
                                }
                            }
                            else{
                                tempDict.setValue(false, forKey: "is_select")
                                tempDict.setValue(1, forKey: "SelectIndex")
                                tempDict.setValue(1, forKey: "copy")
                                tempDict.setValue("\(asset.localIdentifier)", forKey: "id")
                            }
                            tempAry.add(tempDict)
                        }
                    }
                    TmpDic.setValue((tempAry.reversed() as NSArray).mutableCopy() as! NSMutableArray, forKey: coll.localizedTitle!)
                    AryCategoryList.append(coll.localizedTitle!)
                    MainAry.add(TmpDic)
                }
                print("NOT FINDING THe value in  \(coll),\(index)")

            }
            print("AFTER ENUMERATIING")
            
        }
    }
    
    func GetWhatsAppPic()
    {
        let albumList = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        
        albumList.enumerateObjects { (coll, _, _) in
            if let result: PHFetchResult = PHAsset.fetchAssets(in: coll, options: nil) {
                let TmpDic = NSMutableDictionary()
                
                if coll.localizedTitle! == "WhatsApp"
                {
                    let tempAry = NSMutableArray()
                    if result.count > 0 {
                        for i in 0..<result.count{
                            let asset = result.object(at: i)
                            let tempDict = NSMutableDictionary()
                            if self.arySelected.count != 0 {
                                var isCheck = Bool()
                                var copyCount = Int()
                                for j in 0..<self.arySelected.count{
                                    let id = (self.arySelected[j] as NSDictionary).value(forKey: "id") as! String
                                    let selectIndex = (self.arySelected[j] as NSDictionary).value(forKey: "SelectIndex") as! Int
                                    let count = (self.arySelected[j] as NSDictionary).value(forKey: "copy") as! Int
                                    if id == result.object(at: i).localIdentifier && selectIndex == 1 {
                                        isCheck = true
                                        copyCount = count
                                        break;
                                    }
                                    else {
                                        isCheck = false
                                    }
                                }
                                if isCheck {
                                    tempDict.setValue(true, forKey: "is_select")
                                    tempDict.setValue(1, forKey: "SelectIndex")
                                    tempDict.setValue(copyCount, forKey: "copy")
                                    tempDict.setValue("\(asset.localIdentifier)", forKey: "id")
                                }
                                else {
                                    tempDict.setValue(false, forKey: "is_select")
                                    tempDict.setValue(1, forKey: "SelectIndex")
                                    tempDict.setValue(1, forKey: "copy")
                                    tempDict.setValue("\(asset.localIdentifier)", forKey: "id")
                                }
                            }
                            else{
                                tempDict.setValue(false, forKey: "is_select")
                                tempDict.setValue(1, forKey: "SelectIndex")
                                tempDict.setValue(1, forKey: "copy")
                                tempDict.setValue("\(asset.localIdentifier)", forKey: "id")
                            }
                            tempAry.add(tempDict)
                        }
                    }
                    TmpDic.setValue((tempAry.reversed() as NSArray).mutableCopy() as! NSMutableArray, forKey: coll.localizedTitle!)
                    AryCategoryList.append(coll.localizedTitle!)
                    MainAry.add(TmpDic)
                }
            }
        }
    }
    
    func CalculateTiles(AryName : [[String: Any]]) -> Int {
        var finalTilesCnt = Int()
        for (_, item) in AryName.enumerated(){
            let copy = (item as NSDictionary).value(forKey: "copy") as! Int
            finalTilesCnt = finalTilesCnt + copy
            print("Final copy: \(finalTilesCnt), copy: \(copy)")
        }
        return finalTilesCnt
    }
    
    //MARK:- Button Action
    @IBAction func Click_backBtn(_ sender: UIButton) {
        let userdict = NSKeyedArchiver.archivedData(withRootObject: arySelected)
        defaults.setValue(userdict, forKey: keyarymain)
        defaults.synchronize()
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func click_ReviewTiles(_ sender: UIButton) {
        if ApiUtillity.sharedInstance.checkPermission(vc: self) {
            
            let userdict = NSKeyedArchiver.archivedData(withRootObject: arySelected)
            defaults.setValue(userdict, forKey: keyarymain)
            defaults.synchronize()
            
            DispatchQueue.main.async {
                if self.arySelected.count >= self.mimimun_order_quantity {
                    let reviewAdjust = self.storyboard?.instantiateViewController(withIdentifier: "ReviewAdjustVC") as! ReviewAdjustVC
                    self.navigationController?.pushViewController(reviewAdjust, animated: true)
                    
                    if self.isShippingSet != nil {
                        return self.isShippingSet!(false)
                    }
                }
                else {
                    self.showAlert(titleStr: "\(LocalizedLanguage(key: "alert_select_at_least", languageCode: lanCode)) \(self.mimimun_order_quantity) \(LocalizedLanguage(key: "alert_photos", languageCode: lanCode))", msg: "")
                }
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

extension ViewController: PHPhotoLibraryChangeObserver {
    /// - Tag: RespondToChanges
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        // Change notifications may originate from a background queue.
        // Re-dispatch to the main queue before acting on the change,
        // so you can update the UI.
        DispatchQueue.main.sync {
            // Check each of the three top-level fetches for changes.
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
                print("photo in changes") //Update the cached fetch result.
                // allPhotos = changeDetails.fetchResultAfterChanges
                // Don't update the table row that always reads "All Photos."
            }
            
            // Update the cached fetch results, and reload the table sections to match.
            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
                self.getFavouritesImages()
                print("favorites images")
                // smartAlbums = changeDetails.fetchResultAfterChanges
                //  tableView.reloadSections(IndexSet(integer: Section.smartAlbums.rawValue), with: .automatic)
            }
            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
                print("collestion")
                // userCollections = changeDetails.fetchResultAfterChanges
                //  tableView.reloadSections(IndexSet(integer: Section.userCollections.rawValue), with: .automatic)
            }
        }
    }
}


