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

var MainAry = NSMutableArray()
var AryCategoryList = [String]()

class ViewController: BaseViewController, CarbonTabSwipeNavigationDelegate {

    @IBOutlet weak var lblTitles: UILabel!
    @IBOutlet weak var vwSuper: UIView!
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var VwTabView: UIView!
    @IBOutlet weak var lblSelectPhotos: UILabel!
    @IBOutlet weak var btnReviewTiles: UIButton!
   
    var carbonTabSwipeNavigation = CarbonTabSwipeNavigation()
    
    var appDelegate : AppDelegate = AppDelegate()
    var arySelected = [[String:Any]]()
    var ArySelectAdd = NSMutableArray()
    
    var additional_price: Double = 0
    var mimimun_order_quantity: Int = 0
    var price_for_moq: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkPhotoLibraryPermission()
        NotificationCenter.default.addObserver(self, selector: #selector(setCountTiles(_:)), name: Notification.Name("setcount"), object: nil)
        self.setLocalization()
    }

    func setLocalization()
    {
        self.lblTitles.text = LocalizedLanguage(key: "lbl_pick_photo", languageCode: lanCode)
        self.btnReviewTiles.setTitle("  \(LocalizedLanguage(key: "btn_review_tiles", languageCode: lanCode))", for: .normal)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        arySelected = appDelegate.getUserDetails() as! [[String : Any]]
        if arySelected.count != 0{
//            let totalSelectTiles = CalculateTiles(AryName: arySelected)
            self.lblSelectPhotos.text = "  \(arySelected.count) \(LocalizedLanguage(key: "lbl_tiles_selected", languageCode: lanCode))"
        }else{
            self.lblSelectPhotos.text = "  0 \(LocalizedLanguage(key: "lbl_tiles_selected", languageCode: lanCode))"
        }
        
        if let PriceDic = defaults.object(forKey: "price") as? NSDictionary {
            if let tempItem = PriceDic.value(forKey: "additional_price") as? Double { additional_price = tempItem }
            if let tempItem = PriceDic.value(forKey: "mimimun_order_quantity") as? Int { mimimun_order_quantity = tempItem }
            if let tempItem = PriceDic.value(forKey: "price_for_moq") as? Double { price_for_moq = tempItem }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("setcount"), object: nil)
    }
    @IBAction func Click_backBtn(_ sender: UIButton) {
        let userdict = NSKeyedArchiver.archivedData(withRootObject: arySelected)
        defaults.setValue(userdict, forKey: keyarymain)
        defaults.synchronize()
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    @objc func setCountTiles(_ notification: Notification)
    {
        var arySelectTiles = [[String:Any]]()
        var Count : Int = 0
        for (index,item) in MainAry.enumerated()
        {
            let aryItem = (item as! NSDictionary).value(forKey: "\(AryCategoryList[index])") as! NSMutableArray
            
            for item2 in aryItem
            {
                if (item2 as! NSDictionary).value(forKey: "is_select") as! Bool
                {
                        Count += 1
                        arySelectTiles.append(item2 as! [String : Any])
                }
            }
         }
        self.arySelected = arySelectTiles
//        let userdict = NSKeyedArchiver.archivedData(withRootObject: arySelectTiles)
//        defaults.setValue(userdict, forKey: keyarymain)
//        defaults.synchronize()
//        let arySelectOnebyOne = appDelegate.getUserDetails() as! [[String:Any]]
//        let totalSelectTile = CalculateTiles(AryName: arySelectOnebyOne)
        self.lblSelectPhotos.text = "  \(Count) \(LocalizedLanguage(key: "lbl_tiles_selected", languageCode: lanCode))"
    }
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
        //handle authorized status
            print("granted")
            self.GetPhotos()
        case .denied, .restricted :
        //handle denied status
            print("not granted")
        case .notDetermined:
            // ask for permissions
            print("ask for permissions")
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                // as above
                     print("granted")
                    self.GetPhotos()
                case .denied, .restricted:
                 print("not granted")
                case .notDetermined:
                     print("ask for permissions")
                }
            }
        }
    }
    
    @IBAction func click_ReviewTiles(_ sender: UIButton) {
        let userdict = NSKeyedArchiver.archivedData(withRootObject: arySelected)
        defaults.setValue(userdict, forKey: keyarymain)
        defaults.synchronize()
        DispatchQueue.main.async {
            if self.arySelected.count >= self.mimimun_order_quantity {
                let reviewAdjust = self.storyboard?.instantiateViewController(withIdentifier: "ReviewAdjustVC") as! ReviewAdjustVC
                self.navigationController?.pushViewController(reviewAdjust, animated: true)
            }else{
                self.showAlert(titleStr: "\(LocalizedLanguage(key: "alert_select_at_least", languageCode: lanCode)) \(self.mimimun_order_quantity) \(LocalizedLanguage(key: "alert_photos", languageCode: lanCode))", msg: "")
            }
        }
    }
    
    func GetPhotos()
    {
        DispatchQueue.main.async {
            self.showHUD()
            self.GetAllPhotos()
            DispatchQueue.main.async {
                self.GetWhatsAppPic()
                DispatchQueue.main.async(execute: {
                    self.hideHUD()
                    self.Settabbar()
                })
            }
        }
    }
    
    
    func getAssets(fromCollection collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        let photosOptions = PHFetchOptions()
        photosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        photosOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        
        return PHAsset.fetchAssets(in: collection, options: photosOptions)
    }
    
    func Settabbar()
    {
        if AryCategoryList.count != 0{
            carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: AryCategoryList, delegate: self)
            carbonTabSwipeNavigation.insert(intoRootViewController: self, andTargetView:self.VwTabView)
            carbonTabSwipeNavigation.toolbar.isTranslucent = false
            carbonTabSwipeNavigation.setIndicatorColor(UIColor.white)
            carbonTabSwipeNavigation.setTabExtraWidth(30)
            carbonTabSwipeNavigation.setSelectedColor(UIColor.white)
            //        carbonTabSwipeNavigation.carbonSegmentedControl?.setWidth(80, forSegmentAtIndex: 0)
            
            // Custimize segmented control
            let color1 = UIColor.lightText
            self.carbonTabSwipeNavigation.setNormalColor(color1, font: UIFont.boldSystemFont(ofSize: 14))
            self.carbonTabSwipeNavigation.toolbar.setBackgroundImage(#imageLiteral(resourceName: "ic_navbar"), forToolbarPosition: .any, barMetrics: .default)
        }
        
    }
 
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController
    {
        let vc:ImagesVC = self.storyboard?.instantiateViewController(withIdentifier: "ImagesVC") as! ImagesVC
        vc.SelectIndex = Int(index)
        return vc
    }

    func GetAllPhotos()
    {
        MainAry.removeAllObjects()
        AryCategoryList.removeAll()
//        let imgManager = PHImageManager.default()
        let requestOption = PHImageRequestOptions()
        requestOption.isSynchronous = true
        requestOption.deliveryMode = .fastFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        {
            let TmpDic = NSMutableDictionary()
            if fetchResult.count > 0{
                let tempAry = NSMutableArray()
                for i in 0..<fetchResult.count{
                    let tempDict = NSMutableDictionary()
//                    imgManager.requestImage(for: fetchResult.object(at: i), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFit, options: requestOption) { img, error in
//                    }
                    if self.arySelected.count != 0{
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
                            }else{
                                isCheck = false
                            }
                        }
                        if isCheck{
                            //                                tempDict.setValue(img!, forKey: "img")
                            tempDict.setValue(true, forKey: "is_select")
                            tempDict.setValue(0, forKey: "SelectIndex")
                            tempDict.setValue(copyCount, forKey: "copy")
                            tempDict.setValue("\(fetchResult.object(at: i).localIdentifier)", forKey: "id")
                        }else{
                            //                                tempDict.setValue(img!, forKey: "img")
                            tempDict.setValue(false, forKey: "is_select")
                            tempDict.setValue(0, forKey: "SelectIndex")
                            tempDict.setValue(1, forKey: "copy")
                            tempDict.setValue("\(fetchResult.object(at: i).localIdentifier)", forKey: "id")
                        }
                    }else{
                        //                            tempDict.setValue(img!, forKey: "img")
                        tempDict.setValue(false, forKey: "is_select")
                        tempDict.setValue(0, forKey: "SelectIndex")
                        tempDict.setValue(1, forKey: "copy")
                        tempDict.setValue("\(fetchResult.object(at: i).localIdentifier)", forKey: "id")
                    }
                    
                    tempAry.add(tempDict)
                }
                TmpDic.setValue(tempAry, forKey: "All Photos")
                AryCategoryList.append("All Photos")
                MainAry.add(TmpDic)
//                print(MainAry)
            }else{
                print("Not got photos")
            }
            
        }
    }
 
    func GetWhatsAppPic()
    {
        let albumList = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        
        albumList.enumerateObjects { (coll, _, _) in
            let result = self.getAssets(fromCollection: coll)
//            print("\(coll.localizedTitle): \(result.count)")
            let TmpDic = NSMutableDictionary()
            
            if coll.localizedTitle! == "WhatsApp"
            {
                if result.count > 0{
                    
                    let tempAry = NSMutableArray()
                    for i in 0..<result.count{
                        let asset = result.object(at: i)
                        let tempDict = NSMutableDictionary()
                        if self.arySelected.count != 0{
                            var isCheck = Bool()
                            var copyCount = Int()
                            for j in 0..<self.arySelected.count{
                                let id = (self.arySelected[j] as NSDictionary).value(forKey: "id") as! String
                                let selectIndex = (self.arySelected[j] as NSDictionary).value(forKey: "SelectIndex") as! Int
                                let count = (self.arySelected[j] as NSDictionary).value(forKey: "copy") as! Int
                                if id == result.object(at: i).localIdentifier && selectIndex == 1{
                                    isCheck = true
                                    copyCount = count
                                    break;
                                }else{
                                    isCheck = false
                                }
                            }
                            if isCheck{
                                //                                    tempDict.setValue(img!, forKey: "img")
                                tempDict.setValue(true, forKey: "is_select")
                                tempDict.setValue(1, forKey: "SelectIndex")
                                tempDict.setValue(copyCount, forKey: "copy")
                                tempDict.setValue("\(asset.localIdentifier)", forKey: "id")
                            }else{
                                //                                    tempDict.setValue(img!, forKey: "img")
                                tempDict.setValue(false, forKey: "is_select")
                                tempDict.setValue(1, forKey: "SelectIndex")
                                tempDict.setValue(1, forKey: "copy")
                                tempDict.setValue("\(asset.localIdentifier)", forKey: "id")
                            }
                        }else{
                            //                                tempDict.setValue(img!, forKey: "img")
                            tempDict.setValue(false, forKey: "is_select")
                            tempDict.setValue(1, forKey: "SelectIndex")
                            tempDict.setValue(1, forKey: "copy")
                            tempDict.setValue("\(asset.localIdentifier)", forKey: "id")
                        }
//                        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil) { (img, _) in
//
//                        }
                        tempAry.add(tempDict)
                    }
                    TmpDic.setValue(tempAry, forKey: coll.localizedTitle!)
                    AryCategoryList.append(coll.localizedTitle!)
                    MainAry.add(TmpDic)
                    print(MainAry)
                }
            }
        }
    }
    
    func CalculateTiles(AryName : [[String: Any]]) -> Int
    {
        var finalTilesCnt = Int()
        for (_, item) in AryName.enumerated(){
            let copy = (item as NSDictionary).value(forKey: "copy") as! Int
            finalTilesCnt = finalTilesCnt + copy
            print("Final copy: \(finalTilesCnt), copy: \(copy)")
        }
        return finalTilesCnt
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
