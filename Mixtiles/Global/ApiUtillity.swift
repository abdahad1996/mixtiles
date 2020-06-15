//
//  ApiUtillity.swift
//  Trends
//
//  Created by Lead on 24/06/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import SVProgressHUD
import AVFoundation
import Photos

private let _sharedInstance = ApiUtillity()

class ApiUtillity: NSObject {
    
    class var sharedInstance: ApiUtillity {
        return _sharedInstance
    }
    
    // For Check-Permission
    func checkPermission(vc:UIViewController) -> Bool {
        if PHPhotoLibrary.authorizationStatus() == .denied {
            let alert = UIAlertController(title: "Photo Access", message: "Please give this app permission to access your photo library in your settings app!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { (UIAlertAction) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            vc.present(alert, animated: true, completion: nil)
            return false
        }
        else {
            return true
        }
    }
    
    // For Show SVProgressHUD
    func showSVProgressHUD(text:String) {
        if !text.isEmpty {
            SVProgressHUD.show(withStatus: text)
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        }
        else{
            SVProgressHUD.show()
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        }
    }
    
    func dismissSVProgressHUD() {
        SVProgressHUD.dismiss()
    }
    
    func dismissSVProgressHUDWithSuccess(success:String) {
        if !success.isEmpty {
            SVProgressHUD.showSuccess(withStatus: success)
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
            SVProgressHUD.dismiss(withDelay: 2.0)
        }
        else{
            SVProgressHUD.dismiss()
        }
    }
    
    func dismissSVProgressHUDWithError(error:String) {
        if !error.isEmpty {
            SVProgressHUD.showError(withStatus: error)
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
            SVProgressHUD.dismiss(withDelay: 2.0)
        }
        else{
            SVProgressHUD.dismiss()
        }
    }
    
    func dismissSVProgressHUDWithAPIError(error:NSError) {
        if error.code == -1009 {
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        }
        else if error.code == -1004 {
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        }
        else{
            SVProgressHUD.dismiss()
        }
    }
}
