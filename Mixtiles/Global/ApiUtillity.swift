//
//  ApiUtillity.swift
//  Trends
//
//  Created by Lead on 24/06/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import SVProgressHUD

private let _sharedInstance = ApiUtillity()

class ApiUtillity: NSObject {
    
    class var sharedInstance: ApiUtillity {
        return _sharedInstance
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
