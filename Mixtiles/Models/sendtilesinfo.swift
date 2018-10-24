//
//  sendtilesinfo.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 08/09/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import Foundation

class TilesInfoOrder: NSObject{
    
    var order_id : String = ""
    var order_status : String = ""
    var order_date : String = ""
    var user_id : String = ""
    var order_discount : String = ""
    var discount_type : String = ""
    var discounted_price : String = ""
    var total_price : String = ""
    var coupon : String = ""
    var first_name : String = ""
    var last_name : String = ""
    var telephone : String = ""
    var mobile : String = ""
    var email : String = ""
    var recev_emails : String = ""
    var zip : String = ""
    var address : String = ""
    var message : String = ""
    var city :String = ""
    var state : String = ""
    var country : String = ""
    var cpf : String = ""
    
    func initwithdictionary(dict: NSDictionary) -> TilesInfoOrder
    {
        if let itemName = dict["order_id"] as? String {order_id = itemName}
        if let itemName = dict["order_status"] as? String {order_status = itemName}
        if let itemName = dict["order_date"] as? String {order_date = itemName}
        if let itemName = dict["user_id"] as? String {user_id = itemName}
        if let itemName = dict["order_discount"] as? String {order_discount = itemName}
        if let itemName = dict["discount_type"] as? String {discount_type = itemName}
        if let itemName = dict["discounted_price"] as? String {discounted_price = itemName}
        if let itemName = dict["total_price"] as? String {total_price = itemName}
        if let itemName = dict["coupon"] as? String {coupon = itemName}
        if let itemName = dict["first_name"] as? String {first_name = itemName}
        if let itemName = dict["last_name"] as? String {order_id = itemName}
        if let itemName = dict["telephone"] as? String {telephone = itemName}
        if let itemName = dict["mobile"] as? String {mobile = itemName}
        if let itemName = dict["email"] as? String {email = itemName}
        if let itemName = dict["recev_emails"] as? String {recev_emails = itemName}
        if let itemName = dict["zip"] as? String {zip = itemName}
        if let itemName = dict["address"] as? String {address = itemName}
        if let itemName = dict["message"] as? String {message = itemName}
        if let itemName = dict["city"] as? String {city = itemName}
        if let itemName = dict["state"] as? String {state = itemName}
        if let itemName = dict["country"] as? String {country = itemName}
        if let itemName = dict["cpf"] as? String {cpf = itemName}
        
        return self
    }
}

class OrderDetails: NSObject
{
    var id : String = ""
    var user_id : String = ""
    var order_id : String = ""
    var qty : String = ""
    var price : String = ""
    var name : String = ""
    var image : String = ""
    var projectid : String = ""
    var productid : String = ""
    var product_type : String = ""
    var product_size : String = ""
    
    func initwithdictionary(dict: NSDictionary) -> OrderDetails
    {
        if let itemName = dict["id"] as? String {id = itemName}
        if let itemName = dict["user_id"] as? String {user_id = itemName}
        if let itemName = dict["order_id"] as? String {order_id = itemName}
        if let itemName = dict["qty"] as? String {qty = itemName}
        if let itemName = dict["price"] as? String {price = itemName}
        if let itemName = dict["name"] as? String {name = itemName}
        if let itemName = dict["image"] as? String {image = itemName}
        if let itemName = dict["projectid"] as? String {projectid = itemName}
        if let itemName = dict["productid"] as? String {productid = itemName}
        if let itemName = dict["product_type"] as? String {product_type = itemName}
        if let itemName = dict["product_size"] as? String {product_size = itemName}
       return self
    }
}
