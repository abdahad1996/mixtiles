//
//  ImagesVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 27/08/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import Photos

class DCustomButton: UIButton {
    var indexpath: IndexPath?
}

class ImagesVC: BaseViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var Coll_img: UICollectionView!
    @IBOutlet weak var view_lowResolution: UIView!
    @IBOutlet weak var lbl_lowResolution: UILabel!
    @IBOutlet weak var lbl_msglowResolution: UILabel!
    @IBOutlet weak var btn_SelectAnyway: UIButton!
    @IBOutlet weak var btn_DontSelect: UIButton!
    
    //MARK:- Variable Decleration
    var SelectedTab = Int()
    var SelectedIndexpath = IndexPath()
    
    var AryImg = NSMutableArray()
    var vc:ViewController?
    var refreshControl:UIRefreshControl!
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefault()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("UserLoggedIn"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isReloadCollectionView {
            isReloadCollectionView = false
            Coll_img.reloadData()
        }
    }
    
    //MARK:- Private Method
    func setDefault() {
        setLocalization()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = .white
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        Coll_img.addSubview(refreshControl)
        
        DispatchQueue.main.async {
            let MainDict = MainAry.object(at: self.SelectedTab) as! [String:Any]
            self.AryImg = MainDict["\(AryCategoryList[self.SelectedTab])"] as! NSMutableArray
            self.Coll_img.tag = 1
            self.Coll_img.reloadData()
        }
    }
    
    @objc func refresh() {
        if vc != nil {
            vc?.GetAllPhotos()
            vc?.GetWhatsAppPic()
            vc?.getFavouritesImages()
            DispatchQueue.main.async {
                let MainDict = MainAry.object(at: self.SelectedTab) as! [String:Any]
                self.AryImg = MainDict["\(AryCategoryList[self.SelectedTab])"] as! NSMutableArray
                self.Coll_img.tag = 1
                self.Coll_img.reloadData()
                self.refreshControl.endRefreshing()
                self.vc?.setCountTiles()
            }
        }
    }
    
    func setLocalization() {
        self.view_lowResolution.layer.cornerRadius = 10.0
        self.lbl_lowResolution.text = LocalizedLanguage(key: "alert_lowResolution", languageCode: lanCode)
        self.lbl_msglowResolution.text = LocalizedLanguage(key: "alert_msglowResolution", languageCode: lanCode)
        self.btn_SelectAnyway.setTitle(LocalizedLanguage(key: "alert_selectanyway", languageCode: lanCode), for: .normal)
        self.btn_DontSelect.setTitle(LocalizedLanguage(key: "alert_dontSelect", languageCode: lanCode), for: .normal)
    }
    
    @objc func Click_darkBtn(_ sender: DCustomButton) {
        self.view_lowResolution.isHidden = false
        self.SelectedIndexpath = sender.indexpath!
    }
    
    //MARK:- Button Action
    @IBAction func Click_SelectAnyway(_ sender: UIButton) {
        
        var Dict = self.AryImg[self.SelectedIndexpath.row] as! [String:Any]
        if Dict["is_select"] as! Bool {
            Dict.updateValue(false, forKey: "is_select")
        } else {
            Dict.updateValue(true, forKey: "is_select")
        }
        
        self.AryImg.replaceObject(at: self.SelectedIndexpath.row, with: Dict)
        var MainDict = MainAry.object(at: SelectedTab) as! [String:Any]
        MainDict.updateValue(self.AryImg, forKey: "\(AryCategoryList[self.SelectedTab])")
        MainAry.replaceObject(at: SelectedTab, with: MainDict)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.Coll_img.reloadData()
            if self.vc != nil {
                self.vc?.setCountTiles()
            }
        }
        self.view_lowResolution.isHidden = true
    }
    
    @IBAction func Click_DontSelect(_ sender: UIButton) {
        self.view_lowResolution.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ImagesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if AryImg.count <= 0 && Coll_img.tag == 1 {
            let noDataLabel:UILabel = UILabel(frame: Coll_img.frame)
            noDataLabel.text = "imagem não encontrada"
            noDataLabel.font = UIFont(name: "OpenSans-Bold", size: 18.0)
            noDataLabel.textColor = UIColor.white
            noDataLabel.textAlignment = .center
            Coll_img.backgroundView = noDataLabel
        }
        else {
            Coll_img.backgroundView = nil
        }
        return AryImg.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (Coll_img.frame.size.width / 3) - 1
        let size = CGSize(width: width, height: width)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let Cell : imgColl_Cell = Coll_img.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! imgColl_Cell
        let tempDict = self.AryImg[indexPath.row] as! NSDictionary
        requestOption.isSynchronous = true
        requestOption.resizeMode = .exact
        requestOption.deliveryMode = .fastFormat
        requestOption.isNetworkAccessAllowed = true
        
        var img = UIImage()
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [tempDict.value(forKey: "id") as! String], options: .none).firstObject
        Cell.btnDark.isHidden = true
        
        let targetSize = CGSize(width:300, height:300)//CGSize(width:  (asset?.pixelWidth)!, height:  (asset?.pixelHeight)!)
        
        imgManager.requestImage(for: asset!, targetSize: targetSize, contentMode: .aspectFit, options: requestOption) { (image, info) in
            if let image = image {
                img = image
            }
        }
        
        if let isSelect = tempDict.value(forKey: "is_select") as? Bool {
            if isSelect {
                Cell.btnDark.isHidden = false
                Cell.img.image = img
                Cell.btnDark.isUserInteractionEnabled = false
                Cell.btnDark.setImage(UIImage(named: "ic_selectimg"), for: .normal)
            }
            else {
                Cell.img.image = img
                if (asset!.pixelWidth < 800) && (asset!.pixelHeight < 800) {
                    Cell.btnDark.isUserInteractionEnabled = true
                    Cell.btnDark.setImage(UIImage(named: "ic_deselectimg"), for: .normal)
                    Cell.btnDark.isHidden = false
                    Cell.btnDark.indexpath = indexPath
                    Cell.btnDark.addTarget(self, action: #selector(Click_darkBtn(_:)), for: .touchUpInside)
                }
            }
        }
        
        return Cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var Dict: [String:Any] = self.AryImg[indexPath.row] as! [String : Any]
        
        if Dict["is_select"] as! Bool {
            Dict.updateValue(false, forKey: "is_select")
        } else {
            Dict.updateValue(true, forKey: "is_select")
        }
        
        self.AryImg.replaceObject(at: indexPath.row, with: Dict)
        var MainDict = MainAry.object(at: SelectedTab) as! [String:Any]
        MainDict.updateValue(self.AryImg, forKey: "\(AryCategoryList[self.SelectedTab])")
        MainAry.replaceObject(at: SelectedTab, with: MainDict)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.Coll_img.reloadData()
            if self.vc != nil {
                self.vc?.setCountTiles()
            }
        }
    }
}


