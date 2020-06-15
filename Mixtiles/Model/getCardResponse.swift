//
//  getCardResponse.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 05/09/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import Foundation

class CardDetails: NSObject {
    
    var id : String = ""
    var name : String = ""
    var payment_type_id : String = ""
    var status : String = ""
    var secure_thumbnail : String = ""
    var thumbnail : String = ""
    var settings = [[String:Any]]()
    var additional_info_needed = [[String:Any]]()
    
    var mode : String = ""
    var card_location : String = ""
    var length : NSNumber = 0
    var card_no_length : NSNumber = 0
    var pattern : String = ""
    
    func initwithdictionary(dict: [String:Any]) -> CardDetails {

        if let itemName = dict["id"] as? String {id = itemName}
        if let itemName = dict["name"] as? String {name = itemName}
        if let itemName = dict["img"] as? String {thumbnail = itemName}
        if let itemName = dict["card_length"] as? NSNumber {card_no_length = itemName}
        if let itemName = dict["pattern"] as? String {pattern = itemName}
        if let itemName = dict["cvvlength"] as? NSNumber {length = itemName}
        return self
    }
}

class IdentificationType: NSObject {
    
    var id : String = ""
    var name : String = ""
    var type : String = ""
    var max_length : NSNumber = 0
    var min_length : NSNumber = 0
   
    func initwithdictionary(dict: [String:Any]) -> IdentificationType {
        
        if let itemName = dict["id"] as? String {id = itemName}
        if let itemName = dict["name"] as? String {name = itemName}
        if let itemName = dict["type"] as? String {type = itemName}
        if let itemName = dict["min_length"] as? NSNumber {min_length = itemName}
        if let itemName = dict["max_length"] as? NSNumber {max_length = itemName}
        
        return self
    }
}
