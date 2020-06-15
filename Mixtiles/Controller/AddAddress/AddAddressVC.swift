//
//  AddAddressVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 04/09/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import TextFieldEffects
import Alamofire
import AppseeAnalytics
import FBSDKCoreKit
import Firebase

class AddAddressVC: BaseViewController, UITextFieldDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var vwSuper: UIView!
    @IBOutlet weak var vwHeader: UIView!
    
    @IBOutlet weak var txtFullName: HoshiTextField!
    @IBOutlet weak var txtEmail: HoshiTextField!
    @IBOutlet weak var txtPhoneNo: HoshiTextField!
    @IBOutlet weak var txtStreetAddress: HoshiTextField!
    @IBOutlet weak var txtCEP: HoshiTextField!
    @IBOutlet weak var txtStreeNo: HoshiTextField!
    @IBOutlet weak var txtComplement: HoshiTextField!
    @IBOutlet weak var txtNeighborhood: HoshiTextField!
    @IBOutlet weak var txtCity: HoshiTextField!
    @IBOutlet weak var txtState: HoshiTextField!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    
    //MARK:- Variable Declerations
    let kCep: String!         = "cep"
    let kUF: String!          = "uf"
    let kLocalidade: String!  = "localidade"
    let kBairro: String!      = "bairro"
    let kLogradouro: String!  = "logradouro"
    let kComplemento: String! = "complemento"
    let kUnidade: String!     = "unidade"
    let kIbge: String!        = "ibge"
    let kGia: String!         = "gia"
    
    var neighborhood: String = ""
    var currentCountry = ""
    var arrCountryDetail = [AllCountryData]()
    
    var ReviewAndAdjust = ReviewAdjustVC()
    
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentCountry()
        // Do any additional setup after loading the view.
       /// self.btnDone.layer.cornerRadius = self.btnDone.frame.height/2
        self.txtCEP.delegate = self
     
       
        if defaults.value(forKey: keydictAddress) != nil{
            let dictAddress = defaults.value(forKey: keydictAddress) as! NSDictionary
            
            if let fullname = dictAddress.value(forKey: "fullname") as? String{
                self.txtFullName.text = fullname
            }
            if let email = dictAddress.value(forKey: "email") as? String{
                self.txtEmail.text = email
            }
            if let phoneno = dictAddress.value(forKey: "phoneno") as? String{
                self.txtPhoneNo.text = phoneno
            }
            if let address = dictAddress.value(forKey: "address") as? String{
                self.txtStreetAddress.text = address
            }
            if let cep = dictAddress.value(forKey: "cep") as? String{
                self.txtCEP.text = cep
            }
            if let streetno = dictAddress.value(forKey: "streetno") as? String{
                self.txtStreeNo.text = streetno
            }
            if let streetno = dictAddress.value(forKey: "complement") as? String{
                self.txtComplement.text = streetno
            }
            if let streetno = dictAddress.value(forKey: "neighborhood") as? String{
                self.txtNeighborhood.text = streetno
            }
            if let city = dictAddress.value(forKey: "city") as? String{
                self.txtCity.text = city
            }
            if let state = dictAddress.value(forKey: "state") as? String{
                self.txtState.text = state
            }
        }
        
        txtFullName.autocapitalizationType = .words
        self.setLocalization()
    }
    
    //MARK:- Private Method
    func setLocalization() {
        self.lblHeader.text = LocalizedLanguage(key: "lbl_title_add_address", languageCode: lanCode).uppercased()
        self.txtFullName.placeholder = LocalizedLanguage(key: "txt_full_name", languageCode: lanCode)
        self.txtEmail.placeholder = LocalizedLanguage(key: "txt_email", languageCode: lanCode)
        self.txtPhoneNo.placeholder = LocalizedLanguage(key: "txt_cell_phone_number", languageCode: lanCode)
        self.txtCEP.placeholder = LocalizedLanguage(key: "txt_cep_number", languageCode: lanCode)
        self.txtStreetAddress.placeholder = LocalizedLanguage(key: "txt_street_address", languageCode: lanCode)
        self.txtComplement.placeholder = LocalizedLanguage(key: "txt_complement", languageCode: lanCode)
        self.txtNeighborhood.placeholder = LocalizedLanguage(key: "txt_neighborhood", languageCode: lanCode)
        self.txtStreeNo.placeholder = LocalizedLanguage(key: "txt_street_number", languageCode: lanCode)
        self.txtCity.placeholder = LocalizedLanguage(key: "txt_city", languageCode: lanCode)
        self.txtState.placeholder = LocalizedLanguage(key: "txt_state", languageCode: lanCode)
        self.btnDone.setTitle(LocalizedLanguage(key: "btn_done", languageCode: lanCode), for: .normal)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.txtPhoneNo {
            let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return checkEnglishPhoneNumberFormat(string: string, str: str)
        }
        
        if textField == self.txtCEP
        {
            guard string.compactMap({ Int(String($0)) }).count ==
                string.count else { return false }
            
            let text = textField.text ?? ""
            
            if string.count == 0 {
                textField.text = String(text.dropLast()).chunkFormatted()
            }
            else {
                let newText = String((text + string)
                    .filter({ $0 != "-" }).prefix(8))
                textField.text = newText.chunkFormatted()
            }
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtCEP
        {
            let finalCEP = self.txtCEP.text!.replacingOccurrences(of: " ", with: "")
            self.ApiGetAddress(str: finalCEP)
        }
    }
    
    func getCurrentCountry() {
        let arr = getDetailOfAllCountry()
        arrCountryDetail = arr.map(AllCountryData.init)
        currentCountry = "BR"
    }
    
    func getDetailOfAllCountry() -> [[String:Any]]
    {
        var arrCountry = [[String:Any]]()
        if let path = Bundle.main.path(forResource: "postal-codes", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe)
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
                    arrCountry = (jsonResult as! [[String:Any]])
                    return arrCountry
                } catch {}
            } catch {}
        }
        return arrCountry
    }
    
    func validZipCode(postalCode:String)->Bool{
        let exp = arrCountryDetail.filter { $0.ISO == currentCountry}.first
        let postalcodeRegex = exp?.Regex
        if postalcodeRegex == nil {
            return false
        }
        else {
            let pinPredicate = NSPredicate(format: "SELF MATCHES %@", postalcodeRegex!)
            let bool = pinPredicate.evaluate(with: postalCode) as Bool
            return bool
        }
    }
    
    func ApiGetAddress(str: String)
    {
        self.showHUD()
        Alamofire.request("https://viacep.com.br/ws/"+str+"/json", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            self.hideHUD()
            if response.error != nil{
                self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                return
            }
            
            if response.result.value != nil{
                let ResponseDict = response.result.value as! NSDictionary
                print(ResponseDict)
                if ResponseDict.count > 1 {
                    self.preencheDados(ResponseDict)
                }
                else {
                    self.preencheDados(nil)
                }
            }
        }
    }
    
    func preencheDados(_ dict:NSDictionary!) {
        
        if dict != nil {
            if let streetAdd = dict.value(forKey: self.kLogradouro) as? String{
                self.txtStreetAddress.text = streetAdd
            }
            if let CEPno = dict.value(forKey: self.kCep) as? String{
                self.txtCEP.text = CEPno
            }
            if let City = dict.value(forKey: self.kLocalidade) as? String{
                self.txtCity.text = City
            }
            if let state = dict.value(forKey: self.kUF) as? String{
                self.txtState.text = state
            }
            if let neighbor = dict.value(forKey: self.kBairro) as? String{
                self.txtNeighborhood.text = neighbor
            }
            if let complement = dict.value(forKey: self.kComplemento) as? String{
                self.txtComplement.text = complement
            }
        }
    }
    
    @IBAction func Click_backBtn(_ sender: UIButton) {
        ReviewAndAdjust.isShipping = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Click_helpBtn(_ sender: UIButton) {
        let helpvc = storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
        self.navigationController?.present(helpvc, animated: false, completion: nil)
    }
    
    func checkEnglishPhoneNumberFormat(string: String?, str: String?) -> Bool{
        if string == ""{ //BackSpace
            return true
        }
        else if str!.count < 3{
            if str!.count == 1{
                self.txtPhoneNo.text = "("
            }
        }else if str!.count == 4{
            self.txtPhoneNo.text = self.txtPhoneNo.text! + ") "
        }else if str!.count == 11{
            self.txtPhoneNo.text = self.txtPhoneNo.text! + "-"
        }else if str!.count > 15{
            return false
        }
        return true
    }
    
    func validate(value: String) -> Bool {
        let PHONE_REGEX = "^(\\([0-9]{2})\\) [0-9]{5}-[0-9]{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    @IBAction func Click_doneBtn(_ sender: UIButton) {
        
        if self.txtFullName.text!.isEmpty{
            showAlert(titleStr: LocalizedLanguage(key: "alert_msg_full_name", languageCode: lanCode), msg: "")
        }else if txtEmail.text!.isEmpty{
            showAlert(titleStr: LocalizedLanguage(key: "alert_msg_empty_email", languageCode: lanCode), msg: "")
        }else if self.txtEmail.text!.isValidEmail() == false{
            showAlert(titleStr: LocalizedLanguage(key: "alert_msg_valid_email", languageCode: lanCode), msg: "")
        }else if self.txtPhoneNo.text!.isEmpty{
            showAlert(titleStr: LocalizedLanguage(key: "alert_msg_cell_phone_number", languageCode: lanCode), msg: "")
        }else if validate(value: self.txtPhoneNo.text!) == false{
            showAlert(titleStr: LocalizedLanguage(key: "alert_msg_valid_cell_no", languageCode: lanCode), msg: "(##) #####-####")
        }else if self.txtCEP.text!.isEmpty{
            showAlert(titleStr: LocalizedLanguage(key: "alert_msg_cep_number", languageCode: lanCode), msg: "")
        }else if !(validZipCode(postalCode: txtCEP.text!)){
            showAlert(titleStr: LocalizedLanguage(key: "alert_msg_valid_cep_number", languageCode: lanCode), msg: "")
        }else if self.txtStreetAddress.text!.isEmpty{
            showAlert(titleStr: LocalizedLanguage(key: "alert_msg_street_number", languageCode: lanCode), msg: "")
        }else if self.txtNeighborhood.text!.isEmpty{
            showAlert(titleStr: LocalizedLanguage(key: "alert_msg_neighborhood", languageCode: lanCode), msg: "")
        }else if self.txtStreeNo.text!.isEmpty{
            showAlert(titleStr: LocalizedLanguage(key: "alert_msg_street_number", languageCode: lanCode), msg: "")
        }else if self.txtCity.text!.isEmpty{
            showAlert(titleStr: LocalizedLanguage(key: "alert_msg_city", languageCode: lanCode), msg: "")
        }else if self.txtState.text!.isEmpty{
            showAlert(titleStr: LocalizedLanguage(key: "alert_msg_state", languageCode: lanCode), msg: "")
        }
        else {
            let fullname = self.txtFullName.text!.trimmingCharacters(in: .whitespaces)
            let email = self.txtEmail.text!.trimmingCharacters(in: .whitespaces)
            let phoneno = self.txtPhoneNo.text!.trimmingCharacters(in: .whitespaces)
            let address = self.txtStreetAddress.text!.trimmingCharacters(in: .whitespaces)
            let cep = self.txtCEP.text!.trimmingCharacters(in: .whitespaces)
            let city = self.txtCity.text!.trimmingCharacters(in: .whitespaces)
            let state = self.txtState.text!.trimmingCharacters(in: .whitespaces)
            let streetno = self.txtStreeNo.text!.trimmingCharacters(in: .whitespaces)
            let complement = self.txtComplement.text!.trimmingCharacters(in: .whitespaces)
            let neighborhood = self.txtNeighborhood.text!.trimmingCharacters(in: .whitespaces)
            
            let DictAddress = NSMutableDictionary()
            DictAddress.setValue(fullname, forKey: "fullname")
            DictAddress.setValue(email, forKey: "email")
            DictAddress.setValue(phoneno, forKey: "phoneno")
            DictAddress.setValue(address, forKey: "address")
            DictAddress.setValue(streetno, forKey: "streetno")
            DictAddress.setValue(cep, forKey: "cep")
            DictAddress.setValue(city, forKey: "city")
            DictAddress.setValue(state, forKey: "state")
            DictAddress.setValue(complement, forKey: "complement")
            DictAddress.setValue(neighborhood, forKey: "neighborhood")
            print(DictAddress)
            defaults.set(DictAddress, forKey: keydictAddress)
            
            Appsee.addEvent("Address Information", withProperties: [
                                                         "Name" : fullname,
                                                         "Email" : email,
                                                         "Phone Number" : phoneno,
                                                         "Street Number" : streetno,
                                                         "Street Address" : address,
                                                         "Complement" : complement,
                                                         "Neighborhood" : neighborhood,
                                                         "CEP Number" : cep,
                                                         "Date" : NSDate()])
            
            FBSDKAppEvents.logEvent("Address Information", parameters: [
                "Name" : fullname,
                "Email" : email,
                "Phone Number" : phoneno,
                "Street Number" : streetno,
                "Street Address" : address,
                "Complement" : complement,
                "Neighborhood" : neighborhood,
                "CEP Number" : cep])
            
            Analytics.logEvent("AddressInformation", parameters: [
                "Name" : fullname,
                "Email" : email,
                "PhoneNumber" : phoneno,
                "StreetNumber" : streetno,
                "StreetAddress" : address,
                "Complement" : complement,
                "Neighborhood" : neighborhood,
                "CEPNumber" : cep])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class AllCountryData:NSObject {
    var Country = ""
    var ISO = ""
    var Regex = ""
    
    init(dic:[String:Any]) {
        Country = dic["Country"] as? String ?? ""
        ISO = dic["ISO"] as? String ?? ""
        Regex = dic["Regex"] as? String ?? ""
    }
}

extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
