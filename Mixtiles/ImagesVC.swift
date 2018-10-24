//
//  ImagesVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 27/08/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import Photos

protocol SelectPhotoDelegate: class {
    func SelectPhotos(DictPhotos: NSMutableDictionary)
}
class ImagesVC: UIViewController {

    @IBOutlet weak var Coll_img: UICollectionView!
    weak var Delegate : SelectPhotoDelegate?
    
    var SelectIndex = Int()
    
    var AryImg = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Select Index \(SelectIndex)")
        let MainDict = MainAry.object(at: SelectIndex) as! [String:Any]
        self.AryImg = MainDict["\(AryCategoryList[SelectIndex])"] as! NSMutableArray
        
        Coll_img.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isReloadCollectionView{
            isReloadCollectionView = false
            Coll_img.reloadData()
        }
        
    }

    @objc func Click_darkBtn(_ sender: UIButton)
    {
        print(sender.tag)
        
        let Alert = UIAlertController(title: "Low Resolution", message: "This photo is actually pretty small", preferredStyle: .alert)
        Alert.addAction(UIAlertAction(title: "Select Anyway", style: .default, handler: { action in
            print("Select Anyway \(sender.tag)")
            var Dict = self.AryImg[sender.tag] as! [String:Any]
            if Dict["is_select"] as! Bool {
                Dict.updateValue(false, forKey: "is_select")
            }else {
                Dict.updateValue(true, forKey: "is_select")
            }
            self.AryImg.replaceObject(at: sender.tag, with: Dict)
            let MainDict1 = MainAry.object(at: self.SelectIndex) as! [String:Any]
            MainAry.replaceObject(at: self.SelectIndex, with: MainDict1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.Coll_img.reloadData()
            }
            NotificationCenter.default.post(name: Notification.Name("setcount"), object: nil)
            
        }))
        Alert.addAction(UIAlertAction(title: "Don't Select", style: .cancel, handler: { action in
            print("Close")
        }))
        self.present(Alert, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ImagesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.AryImg.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Coll_img.frame.size.width / 3 - 1
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
        requestOption.deliveryMode = .fastFormat
        var img = UIImage()
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [tempDict.value(forKey: "id") as! String], options: .none).firstObject
        imgManager.requestImage(for: asset!, targetSize: CGSize(width: 200.0, height: 200.0), contentMode: .aspectFit, options: requestOption, resultHandler: { result, info in
            img = result!
        })
        
        let image: UIImage = img
        let size = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
//        print(size)
        Cell.btnDark.isHidden = true
        if let isSelect = tempDict.value(forKey: "is_select") as? Bool
        {
            if isSelect{
                Cell.btnDark.isHidden = false
                Cell.img.image = img
                Cell.btnDark.isUserInteractionEnabled = false
                Cell.btnDark.setImage(UIImage(named: "ic_selectimg"), for: .normal)
            }else{
                Cell.img.image = img
                if size.width < 300.0 && size.height < 300.0{
                    Cell.btnDark.isUserInteractionEnabled = true
                    Cell.btnDark.setImage(UIImage(named: "ic_deselectimg"), for: .normal)
                    Cell.btnDark.isHidden = false
                    Cell.btnDark.tag = indexPath.row
                    Cell.btnDark.addTarget(self, action: #selector(Click_darkBtn(_:)), for: .touchUpInside)
                }
            }
        }
        return Cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var Dict = self.AryImg[indexPath.row] as! [String:Any]
        if Dict["is_select"] as! Bool {
            Dict.updateValue(false, forKey: "is_select")
        }else {
            Dict.updateValue(true, forKey: "is_select")
        }
        self.AryImg.replaceObject(at: indexPath.row, with: Dict)
        let MainDict1 = MainAry.object(at: SelectIndex) as! [String:Any]
        MainAry.replaceObject(at: SelectIndex, with: MainDict1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.Coll_img.reloadData()
        }
        NotificationCenter.default.post(name: Notification.Name("setcount"), object: Dict)
        
    }
}

