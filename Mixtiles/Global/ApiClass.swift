//
//  ApiClass.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 05/09/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import Foundation

var AccessToken = "TEST-974857002126122-082101-55a1073dd12be973e669791da286d719-312679110" //test
//var AccessToken = "APP_USR-974857002126122-082101-0b3bffd1c8d93086cce4aa1f9a613815-312679110" //live

var baseUrl = "https://api.mercadopago.com/v1/"
//var clientBaseUrl = "http://14augest.14augusthotel.com/brickart/index.php/api/" //Test
var clientBaseUrl = "http://www.brickart.com.br/fotos/index.php/api/" //Live
var Mpayment_methods = "\(baseUrl)payment_methods?access_token=\(AccessToken)"
var Midentification_types = "\(baseUrl)identification_types?access_token=\(AccessToken)"
var Mcard_tokens = "\(baseUrl)card_tokens?access_token=\(AccessToken)"
var Mpayments = "\(baseUrl)payments?access_token=\(AccessToken)"
var MBoletopayments = "\(baseUrl)payments?access_token=\(AccessToken)"
var MCheckPromocode = "\(clientBaseUrl)CheckPromocode"
var Msendtilesinfo = "\(clientBaseUrl)sendtilesinfo"
var MupdateOrderTiles = "\(clientBaseUrl)updateOrderTiles"
var MSavePayment = "\(clientBaseUrl)SavePayment"
