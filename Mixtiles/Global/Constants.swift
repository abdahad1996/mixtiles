//
//  Constants.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 29/08/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import Foundation
import UIKit
import Photos

var keyarymain = "arymain"
var keydictAddress = "dictaddress"
var keydictcreditcard = "dictcreditcard"
var keycpfno = "cpfno"
var keyTokenCreditCard = "token"
var keyPaymentMethod = "cardtype"
var keyIsintroduction = "isintroduction"
var keyCardIndex = "cardindex"
var keySelectedInstallment = "SelectedInstallment"

var user = "admin"
var password = "1234"

var lanCode = String()

var defaults = UserDefaults.standard
var unReadMsgCnt = 0
var isReloadCollectionView = false
let requestOption = PHImageRequestOptions()
let imgManager = PHImageManager.default()

struct color
{
    static let themeColor = "ff005c"
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

extension UIView{
    
    func SetRediousView()
    {
        self.layer.cornerRadius = 5.0
    }
    
    func SetHeightByRadious()
    {
        self.layer.cornerRadius = self.frame.size.height/2
    }
    
    func SetBorderWithRadiusView(colours: UIColor) -> Void
    {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = colours.cgColor
    }
    
    func Shadow()
    {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
    }
    
    func ShadowWithOpacity()
    {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.clear.cgColor
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.6
        self.layer.masksToBounds = false;
    }
    
    func ShadowWithColor()
    {
        self.layer.shadowColor = getColorIntoHex(Hex: "2BC7B1").cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false;
    }
}

extension UIButton{
    
    func SetRediousBtn()
    {
        self.layer.cornerRadius = 5.0
    }
    
    func SetBorderWithRadius(colours: UIColor) -> Void
    {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = colours.cgColor
    }
    
    func SetBorderWithRediusAndColor(colours: UIColor) -> Void
    {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        //        self.layer.borderColor = colours.cgColor
        self.backgroundColor = colours
    }
}


extension UITextField
{
    func setRounded(toRadious : Float)
    {
        self.layer.cornerRadius = CGFloat(toRadious)
        setLeftSpace()
    }
    func setLeftSpace()
    {
        let spaceView = UIView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 30))
        spaceView.backgroundColor = .clear
        self.leftView = spaceView;
        self.leftViewMode = .always
    }
}

func getColorIntoHex(Hex:String) -> UIColor {
    if Hex.isEmpty {
        return UIColor.clear
    }
    let scanner = Scanner(string: Hex)
    scanner.scanLocation = 0
    var rgbValue: UInt64 = 0
    scanner.scanHexInt64(&rgbValue)
    let r = (rgbValue & 0xff0000) >> 16
    let g = (rgbValue & 0xff00) >> 8
    let b = rgbValue & 0xff
    return UIColor.init(red: CGFloat(r) / 0xff, green: CGFloat(g) / 0xff, blue: CGFloat(b) / 0xff, alpha: 1)
}

func LocalizedLanguage(key:String,languageCode:String)->String{
    
    var path = Bundle.main.path(forResource: languageCode, ofType: "lproj")
    path = (path != nil ? path:"")
    
    let languageBundle:Bundle!
    
    if(FileManager.default.fileExists(atPath: path!)){
        languageBundle = Bundle(path: path!)
        return languageBundle!.localizedString(forKey: key, value: "", table: nil)
    }else{
        path = Bundle.main.path(forResource: "Base", ofType: "lproj")
        languageBundle = Bundle(path: path!)
        return languageBundle!.localizedString(forKey: key, value: "", table: nil)
    }
}

