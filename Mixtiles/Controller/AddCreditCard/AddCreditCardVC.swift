//
//  AddCreditCardVC.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 04/09/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import DropDown
import Alamofire
import SDWebImage
import TextFieldEffects
import CPF_CNPJ_Validator
import Firebase
import AppseeAnalytics
import FBSDKCoreKit
import Firebase
protocol paymentTokenDelegate: class {
    func paymentToken(token: String, paymentid: String, cpf: String)
}

class AddCreditCardVC: BaseViewController, UITextFieldDelegate {

    //MARK:- Outlets
    @IBOutlet weak var Coll_CardView: UICollectionView!
    @IBOutlet weak var txtCardHolderName: HoshiTextField!
    @IBOutlet weak var txtCardNumber: HoshiTextField!
    @IBOutlet weak var txtCardMonth: HoshiTextField!
    @IBOutlet weak var txtSecurityCode: HoshiTextField!
    @IBOutlet weak var txtCPFNo: HoshiTextField!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var txtInstallment: HoshiTextField!
    
    @IBOutlet weak var cardValidationLabel: UILabel!
    @IBOutlet weak var cardTypeLabel: UILabel!
    
    @IBOutlet weak var view_HideforBoleto: UIView!
    @IBOutlet weak var constant_HeightforBoleto: NSLayoutConstraint!
    
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var img_mercadopago: UIImageView!
    
    @IBOutlet weak var btnDropDown: UIButton!
    //MARK:- Variable Declerations
    weak var delegate : paymentTokenDelegate?
    
    var aryCardDetails = NSMutableArray()
    var aryIdentiType = NSMutableArray()
    var isCardSelect = false
    var isSelectIndex : Int = -1
    var SecurityCodeLen : NSNumber = 0
    var CardNumberLen : NSNumber = 0
    var CPFMaxLimit : NSNumber = 0
    var CPFMinLimit = NSNumber()
    var patternStr = String()
    var payment_method_id = String()
    
    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?
    var creditCardValidator: CreditCardValidator!
    var isShippingSet:((Bool)->())?
    let dropDown = DropDown()
    let myCustomCard = CardIOView()
    let upView = UIView()
    let bottomVIew = UIView()
    let arrInstallment = ["A vista","2 x sem juros","3 x sem juros"]
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtInstallment.text = "1"
        self.preload()
        self.setDefault()
        self.setLocalization()
        self.ApiGetPaymentMethods()
    }

    //MARK:- Private Method
    func setDefault() {
        txtCardNumber.delegate = self
        txtCardMonth.delegate = self
        txtSecurityCode.delegate = self
        txtCPFNo.delegate = self
        DropDown.startListeningToKeyboard()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = formatter.string(from: Date())
        
        self.img_mercadopago.sd_setShowActivityIndicatorView(true)
        self.img_mercadopago.sd_setIndicatorStyle(.gray)
        self.img_mercadopago.sd_setImage(with: URL(string: "https://www.brickart.com.br/mobile_app/seguranca_pagamento.jpg?date="+date), completed: nil)
        
        creditCardValidator = CreditCardValidator()
      //  self.btnAdd.layer.cornerRadius = self.btnAdd.frame.size.height/2
        
        txtCardNumber.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
        
        if defaults.value(forKey: keydictcreditcard) != nil {
//            print(defaults.value(forKey: keydictcreditcard)!)
            let dictCard = defaults.value(forKey: keydictcreditcard) as! NSDictionary
            let cardHolder = dictCard.value(forKey: "cardholder") as! NSDictionary
            
            if let name = cardHolder.value(forKey: "name") as? String{
                self.txtCardHolderName.text = name
            }
            
            if let cardno = dictCard.value(forKey: "card_number") as? String{
                let finalcardno = cardno.pairs.joined(separator: " ")
                self.txtCardNumber.text = finalcardno
            }
            
            if let emonth = dictCard.value(forKey: "expiration_month") as? String, let eyear = dictCard.value(forKey: "expiration_year") as? String{
                self.txtCardMonth.text = emonth+"/"+eyear
            }
        }
        
        if let installment = defaults.value(forKey: keySelectedInstallment) as? String
        {
            txtInstallment.text = arrInstallment[(Int(installment)!-1)]//installment
        }
        else
        {
            txtInstallment.text = arrInstallment[0]
            defaults.set("\(self.selectedInstallment())", forKey: keySelectedInstallment)
        }
        self.txtCardHolderName.autocapitalizationType = .words
    }
    
    func setLocalization() {
        self.lblHeaderTitle.text = LocalizedLanguage(key: "lbl_title_add_credit_card", languageCode: lanCode).uppercased()
        self.txtCardHolderName.placeholder = LocalizedLanguage(key: "txt_card_holder_name", languageCode: lanCode)
        self.txtCardNumber.placeholder = LocalizedLanguage(key: "txt_card_number", languageCode: lanCode)
        self.txtCardMonth.placeholder = LocalizedLanguage(key: "txt_mmyyyy", languageCode: lanCode)
        self.txtSecurityCode.placeholder = LocalizedLanguage(key: "txt_security_code", languageCode: lanCode)
        self.txtCPFNo.placeholder = LocalizedLanguage(key: "txt_cpf_number", languageCode: lanCode)
        self.btnAdd.setTitle(LocalizedLanguage(key: "btn_add", languageCode: lanCode), for: .normal)
        self.txtInstallment.placeholder = LocalizedLanguage(key: "txt_select_installment", languageCode: lanCode)
        
       // "txt_select_installment" = "Numero de parcelas";
       
    }
    
    /**
     Credit card validation
     
     - parameter number: credit card number
     */
    func validateCardNumber(number: String) {
        if creditCardValidator.validate(string: number) {
            self.cardValidationLabel.text = LocalizedLanguage(key: "card_no_valid", languageCode: lanCode)
            self.cardValidationLabel.textColor = UIColor.green
        } else {
            self.cardValidationLabel.text = LocalizedLanguage(key: "card_no_invalid", languageCode: lanCode)
            self.cardValidationLabel.textColor = UIColor.red
        }
    }
    
    func selectedInstallment()-> Int
    {
        for i in 0..<arrInstallment.count
        {
            if(txtInstallment.text! == arrInstallment[i])
            {
                return i+1
            }
        }
        return 1
    }
    /**
     Credit card type detection
    
     - parameter number: credit card number
     */
    func detectCardNumberType(number: String) {
        if let type = creditCardValidator.type(from: number) {
            self.cardTypeLabel.text = type.name
            self.cardTypeLabel.textColor = UIColor.green
        } else {
            self.cardTypeLabel.text = "Undefined"
            self.cardTypeLabel.textColor = UIColor.red
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if textField == self.txtCardNumber {
            
            if CardNumberLen != 0 {
                previousTextFieldContent = textField.text;
                previousSelection = textField.selectedTextRange;
                return true
            }
            else {
                showAlert(titleStr: LocalizedLanguage(key: "alert_select_credit_card", languageCode: lanCode), msg: "")
            }
        }
        if textField == self.txtCardMonth {
            let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return checkExpirationDate(string: string, str: str)
        }
        
        if textField == self.txtSecurityCode {
            if SecurityCodeLen != 0{
                return updatedText.count <= Int(truncating: SecurityCodeLen)
            }
            else{
                showAlert(titleStr: LocalizedLanguage(key: "alert_select_credit_card", languageCode: lanCode), msg: "")
            }
        }
        
        if textField == self.txtCPFNo {
            let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return checkCPFNumberFormat(string: string, str: str)
        }
        
       return true
    }
    
    func checkExpirationDate(string: String?, str: String?) -> Bool{
        if string == "" {
            return true
        }
        else if str!.count == 3 {
            self.txtCardMonth.text = self.txtCardMonth.text! + "/"
        }
        else if str!.count > 7 {
            return false
        }
        return true
    }
    
    func checkCPFNumberFormat(string: String?, str: String?) -> Bool{
        if string == "" {
            return true
        }
        else if str!.count == 4 {
            self.txtCPFNo.text = self.txtCPFNo.text! + "."
        }
        else if str!.count == 8 {
            self.txtCPFNo.text = self.txtCPFNo.text! + "."
        }
        else if str!.count == 12 {
            self.txtCPFNo.text = self.txtCPFNo.text! + "-"
        }
        else if str!.count > 14 {
            return false
        }
        return true
    }
    
    @objc func reformatAsCardNumber(textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }
        
        var cardNumberWithoutSpaces = ""
        if let text = textField.text {
            cardNumberWithoutSpaces = self.removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }
        
        if cardNumberWithoutSpaces.count > Int(truncating: CardNumberLen) {
            textField.text = previousTextFieldContent
            textField.selectedTextRange = previousSelection
            return
        }
        
        let cardNumberWithSpaces = self.insertCreditCardSpaces(cardNumberWithoutSpaces, preserveCursorPosition: &targetCursorPosition)
        textField.text = cardNumberWithSpaces
        
        if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
    }
    
    func removeNonDigits(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var digitsOnlyString = ""
        let originalCursorPosition = cursorPosition
        
        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if characterToAdd >= "0" && characterToAdd <= "9" {
                digitsOnlyString.append(characterToAdd)
            }
            else if i < originalCursorPosition {
                cursorPosition -= 1
            }
        }
        
        return digitsOnlyString
    }
    
    func insertCreditCardSpaces(_ string: String, preserveCursorPosition cursorPosition: inout Int) -> String {
        /*
         Mapping of card prefix to pattern is taken from
         https://baymard.com/checkout-usability/credit-card-patterns
         UATP cards have 4-5-6 (XXXX-XXXXX-XXXXXX) format
         
         let is456 = string.hasPrefix("1")
         These prefixes reliably indicate either a 4-6-5 or 4-6-4 card. We treat all these
         as 4-6-5-4 to err on the side of always letting the user type more digits.
         In all other cases, assume 4-4-4-4-3.
         
         This won't always be correct; for instance, Maestro has 4-4-5 cards according
         to https://baymard.com/checkout-usability/credit-card-patterns, but I don't
         know what prefixes identify particular formats.
        */
        let is465 = ["34", "37"].contains { string.hasPrefix($0) }
        let is4444 = !(is465)
        
        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition
        
        for i in 0..<string.count {
            let needs465Spacing = (is465 && (i == 4 || i == 10 || i == 15))
//            let needs456Spacing = (is456 && (i == 4 || i == 9 || i == 15))
            let needs4444Spacing = (is4444 && i > 0 && (i % 4) == 0)
            
            if needs465Spacing || needs4444Spacing {
                stringWithAddedSpaces.append(" ")
                
                if i < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
            
            let characterToAdd = string[string.index(string.startIndex, offsetBy:i)]
            stringWithAddedSpaces.append(characterToAdd)
        }
        
        return stringWithAddedSpaces
    }
    
    func isNumberValidation(testStr:String) -> Bool {
        let emailRegEx = patternStr
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func ApiGetPaymentMethods()
    {
        if let path = Bundle.main.path(forResource: "card", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? NSDictionary{
                    let person = jsonResult["data"] as? NSArray
                    let AryRList = NSMutableArray(array: person!)
                    for i in 0..<AryRList.count
                    {
                        let carddetail = CardDetails().initwithdictionary(dict: AryRList[i] as! [String: Any])
                        if(carddetail.name.lowercased() != "boleto")
                        {
                            self.aryCardDetails.add(carddetail)
                        }
                        else
                        {
                            print(carddetail.name)
                        }
                    }
                    
                    if Reachability.isConnectedToNetwork() {
                        self.ApiGetIdentiType()
                    }
                    else {
                        showAlert(titleStr: LocalizedLanguage(key: "alert_network", languageCode: lanCode), msg: "")
                    }
                    
                    DispatchQueue.main.async(execute: {
                        
                        if defaults.value(forKey: keyCardIndex) != nil{
                            if let index = defaults.value(forKey: keyCardIndex) as? Int{
                                
                                let indexPath = IndexPath(item: index, section: 0)
                                let cell = self.Coll_CardView.cellForItem(at: indexPath)
                                cell?.layer.borderColor = UIColor.blue.cgColor
                                self.isSelectIndex = index
                                
                                self.Coll_CardView.scrollToItem(at: indexPath, at: .left, animated: false)
                                if index == 7 {
                                    self.constant_HeightforBoleto.constant = 0
                                    self.view_HideforBoleto.isHidden = true
                                }
                                else {
                                    self.constant_HeightforBoleto.constant = 180
                                    self.view_HideforBoleto.isHidden = false
                                }
                                
                                let dictTemp = self.aryCardDetails.object(at: index) as! CardDetails
                                self.payment_method_id = dictTemp.id
                                self.SecurityCodeLen = dictTemp.length
                                self.CardNumberLen = dictTemp.card_no_length
                                self.patternStr = dictTemp.pattern
                            }
                        }
                        
                        if defaults.value(forKey: keycpfno) != nil{
                            if let CPFNo = defaults.value(forKey: keycpfno) as? String{
                                self.txtCPFNo.text = CPFNo
                            }
                        }
                    })
                }
            } catch {
                // handle error
            }
        }
    }
    
    func ApiGetIdentiType() {
        
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(Midentification_types, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { response in
//            debugPrint(response)
            
            if let json = response.result.value {
                let tempArray: NSArray = json as! NSArray
                let ListArray: NSMutableArray = NSMutableArray(array: tempArray)
                
                for item in ListArray {
                    let identificationType = IdentificationType().initwithdictionary(dict: item as! [String: Any])
                    self.aryIdentiType.add(identificationType)
                }
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
            }
            else {
                self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
            }
        }
    }
    
    func ApiPostCardTokens(dict : NSDictionary) {
        
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(Mcard_tokens, method: .post, parameters: (dict as! [String:Any]), encoding: JSONEncoding.default, headers: nil).responseJSON { response in
//            debugPrint(response)
            
            if let json = response.result.value {
                let dict:NSDictionary = (json as? NSDictionary)!
                defaults.set("\(self.selectedInstallment())", forKey: keySelectedInstallment)
                if let Status = dict.value(forKey: "status") as? String, Status == "active" {
                    
                    if let id = dict.value(forKey: "id") as? String {
                        ApiUtillity.sharedInstance.dismissSVProgressHUD()
                        
                        self.delegate?.paymentToken(token: id, paymentid: self.payment_method_id, cpf: "")
                        defaults.set(id, forKey: keyTokenCreditCard)
                        defaults.set(self.payment_method_id, forKey: keyPaymentMethod)
                        self.navigationController?.popViewController(animated: true)
                        if self.isShippingSet != nil {
                            return self.isShippingSet!(true)
                        }
                    }
                }
                else {
                    if let message = dict.value(forKey: "message") as? String {
                        self.showAlert(titleStr: "\(message)", msg: "")
                        ApiUtillity.sharedInstance.dismissSVProgressHUD()
                    }
                }
            }
            else {
                self.showAlert(titleStr: LocalizedLanguage(key: "alert_missing", languageCode: lanCode), msg: "")
                ApiUtillity.sharedInstance.dismissSVProgressHUD()
            }
        }
    }
    
    
    func setupRightBarDropDown(arr:[String])
    {
        
        dropDown.anchorView = btnDropDown
        dropDown.dataSource = arr
        dropDown.direction = .any
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.txtInstallment.text = self.arrInstallment[index]
            print("Selected item: \(item) at index: \(index)")
        }
    }
    //MARK:- Button Action
    
    @IBAction func btnInstallmentTapped(_ sender: UIButton) {
        setupRightBarDropDown(arr: arrInstallment)
        dropDown.show()
    }
    
    @IBAction func btnCardScanTapped(_ sender: UIButton) {
        self.scanViewDisplay()
    }
    
    @IBAction func CheckCardNumber(_ sender: UITextField) {
        if let number = sender.text {
            if number.isEmpty {
                self.cardValidationLabel.text = LocalizedLanguage(key: "alert_card_no", languageCode: lanCode)
                self.cardValidationLabel.textColor = UIColor.black
                
                self.cardTypeLabel.text = LocalizedLanguage(key: "alert_card_no", languageCode: lanCode)
                self.cardTypeLabel.textColor = UIColor.black
            }
            else {
                validateCardNumber(number: number)
                detectCardNumberType(number: number)
            }
        }
    }
    
    @IBAction func Click_backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        if isShippingSet != nil {
            return isShippingSet!(true)
        }
    }
    
    @IBAction func Click_helpBtn(_ sender: UIButton) {
        let helpvc = storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
        self.navigationController?.present(helpvc, animated: false, completion: nil)
    }
    
    @IBAction func Click_addBtn(_ sender: UIButton) {
        //by original
        let success = BooleanValidator().validate(cpf: self.txtCPFNo.text!)
        if payment_method_id == "bolbradesco" {
            if self.txtCPFNo.text!.isEmpty{
                showAlert(titleStr: LocalizedLanguage(key: "alert_cpf_no", languageCode: lanCode), msg: "")
            }
            else if success == false {
                showAlert(titleStr: LocalizedLanguage(key: "alert_cpf_no_invalid", languageCode: lanCode), msg: "")
            }
            else {
                defaults.set(self.payment_method_id, forKey: keyPaymentMethod)
                defaults.set(isSelectIndex, forKey: keyCardIndex)
                defaults.set(self.txtCPFNo.text!, forKey: keycpfno)
                
                Appsee.addEvent("Boleto Information", withProperties: [
                    "CPF Number" : self.txtCPFNo.text!,
                    "Payment Method" : payment_method_id,
                    "Date" : NSDate()])
                
                FBSDKAppEvents.logEvent("Boleto Information", parameters: [
                    "CPF Number" : self.txtCPFNo.text!,
                    "Payment Method" : payment_method_id])
                
                Analytics.logEvent("BoletoInformation", parameters: [
                    "CPFNumber" : self.txtCPFNo.text!,
                    "PaymentMethod" : payment_method_id])
                
                self.delegate?.paymentToken(token: "", paymentid: "", cpf: self.txtCPFNo.text!)
                self.navigationController?.popViewController(animated: true)
                if self.isShippingSet != nil {
                    return self.isShippingSet!(true)
                }
            }
        }
        else {
            if self.txtCardHolderName.text!.isEmpty{
                showAlert(titleStr: LocalizedLanguage(key: "alert_card_holder_name", languageCode: lanCode), msg: "")
            }
            else if txtCardNumber.text!.isEmpty{
                showAlert(titleStr: LocalizedLanguage(key: "alert_card_no", languageCode: lanCode), msg: "")
            }
            else if (self.txtCardNumber.text!.replacingOccurrences(of: " ", with: "")).isValidCard(value: patternStr) == false {
                showAlert(titleStr: LocalizedLanguage(key: "alert_card_no_invalid", languageCode: lanCode), msg: "")
            }
            else if self.txtCardMonth.text!.isEmpty || self.txtCardMonth.text!.count < 2 {
                showAlert(titleStr: LocalizedLanguage(key: "alert_mmyyyy", languageCode: lanCode), msg: "")
            }
            else if self.txtCardMonth.text!.count < 7 {
                showAlert(titleStr: LocalizedLanguage(key: "alert_mmyyyy", languageCode: lanCode), msg: "")
            }
            else if self.txtSecurityCode.text!.isEmpty{
                showAlert(titleStr: LocalizedLanguage(key: "alert_security_code", languageCode: lanCode), msg: "")
            }
            else if self.txtSecurityCode.text!.count < 3 {
                showAlert(titleStr: LocalizedLanguage(key: "alert_security_code_invalid", languageCode: lanCode), msg: "")
            }
            else if self.txtCPFNo.text!.isEmpty{
                showAlert(titleStr: LocalizedLanguage(key: "alert_cpf_no", languageCode: lanCode), msg: "")
            }
            else if success == false{
                showAlert(titleStr: LocalizedLanguage(key: "alert_cpf_no_invalid", languageCode: lanCode), msg: "")
            }
            else {
                let finalCardNo = self.txtCardNumber.text!.replacingOccurrences(of: " ", with: "")
                let dictTemp = NSMutableDictionary()
                
                var month: String = ""
                var year: String = ""
                let ExpiryDate = self.txtCardMonth.text!.components(separatedBy: "/")
                month = ExpiryDate[0]
                year = ExpiryDate[1]
                
                let dictCardHolder = NSMutableDictionary()
                let Dictidentification = NSMutableDictionary()
                
                dictTemp.setValue("\(finalCardNo)", forKey: "card_number")
                dictTemp.setValue(month, forKey: "expiration_month")
                dictTemp.setValue(year, forKey: "expiration_year")
                dictTemp.setValue("\(self.txtSecurityCode.text!)", forKey: "security_code")
                dictTemp.setValue(dictCardHolder, forKey: "cardholder")
                
                Dictidentification.setValue("CPF", forKey: "type")
                Dictidentification.setValue("\(self.txtCPFNo.text!)", forKey: "number")
                dictCardHolder.setValue(Dictidentification, forKey: "identification")
                dictCardHolder.setValue("\(self.txtCardHolderName.text!)", forKey: "name")
                
//                print(dictTemp)
                
                defaults.set(dictTemp, forKey: keydictcreditcard)
                defaults.set(isSelectIndex, forKey: keyCardIndex)
                defaults.set(self.txtCPFNo.text!, forKey: keycpfno)
                
                Appsee.addEvent("Credit Card Information", withProperties: [
                    "CPF Number" : self.txtCPFNo.text!,
                    "Card Holder Name" : self.txtCardHolderName.text!,
                    "Payment Method" : payment_method_id,
                    "Expiry Date" : self.txtCardMonth.text!,
                    "installments" : "\(self.selectedInstallment())",
                    ])
                
                FBSDKAppEvents.logEvent("Credit Card Information", parameters: [
                    "CPF Number" : self.txtCPFNo.text!,
                    "Card Holder Name" : self.txtCardHolderName.text!,
                    "Payment Method" : payment_method_id,
                    "Expiry Date" : self.txtCardMonth.text!,
                    "installments" : "\(self.selectedInstallment())"])
                
                Analytics.logEvent("CreditCardInformation", parameters: [
                    "CPFNumber" : self.txtCPFNo.text!,
                    "CardHolderName" : self.txtCardHolderName.text!,
                    "PaymentMethod" : payment_method_id,
                    "ExpiryDate" : self.txtCardMonth.text!,
                    "installments" : "\(self.selectedInstallment())",
                    ])
                print(dictTemp)
                if Reachability.isConnectedToNetwork() {
                    ApiPostCardTokens(dict: dictTemp)
                }
                else {
                    showAlert(titleStr: LocalizedLanguage(key: "alert_network", languageCode: lanCode), msg: "")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension AddCreditCardVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryCardDetails.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let Cell : AddCreditCard_Cell = Coll_CardView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AddCreditCard_Cell
        
        let dictTemp = aryCardDetails.object(at: indexPath.row) as! CardDetails
        
        Cell.imgCreditCard.image = UIImage(named: "\(dictTemp.thumbnail)")
        Cell.layer.borderWidth = 1.0
        Cell.layer.borderColor = UIColor.lightGray.cgColor
        Cell.layer.cornerRadius = 5.0
        Cell.contentView.backgroundColor = UIColor.white
        if indexPath.row == isSelectIndex {
            Cell.layer.borderColor = UIColor.blue.cgColor
            isSelectIndex = indexPath.row
        }
        return Cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:
        IndexPath) {
        let dictTemp = aryCardDetails.object(at: indexPath.row) as! CardDetails
        payment_method_id = dictTemp.id
        SecurityCodeLen = dictTemp.length
        CardNumberLen = dictTemp.card_no_length
        patternStr = dictTemp.pattern
        isSelectIndex = indexPath.row
        
        if dictTemp.id == "bolbradesco" {
            self.constant_HeightforBoleto.constant = 0
            self.view_HideforBoleto.isHidden = true
        }
        else {
            self.constant_HeightforBoleto.constant = 180
            self.view_HideforBoleto.isHidden = false
        }
        
        Coll_CardView.reloadData()
        isCardSelect = true
    }
}


extension AddCreditCardVC:CardIOViewDelegate
{
    
    func preload()
    {
        CardIOUtilities.preload()
    }
    
    func scanViewDisplay()
    {
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        //  cardIOVC?.collectCardholderName = true
        cardIOVC?.modalPresentationStyle = .formSheet
        cardIOVC?.collectCVV = false
        cardIOVC?.suppressScanConfirmation = false
        cardIOVC?.disableManualEntryButtons = true
        cardIOVC?.useCardIOLogo = false
        cardIOVC?.guideColor = UIColor.red
        cardIOVC?.disableBlurWhenBackgrounding = true
        cardIOVC?.setNeedsUpdateOfHomeIndicatorAutoHidden()
        myCustomCard.guideColor = UIColor.red
        myCustomCard.delegate = self
        myCustomCard.frame = CGRect(x:0,y:0,width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(myCustomCard)
        
        upView.frame = CGRect(x:0,y:0,width: self.view.frame.size.width, height: 130)
        upView.backgroundColor = UIColor.black
        
        let cancelButton = UIButton()
        cancelButton.frame = CGRect(x:10,y:10,width:100,height:50)
        cancelButton.addTarget(self, action: #selector(cancelTapped(sender:)), for: .touchUpInside)
        // "btn_addCard_close" = "Voltar";
        cancelButton.setTitle(LocalizedLanguage(key: "btn_addCard_close", languageCode: lanCode), for: .normal)
       // cancelButton.setTitle("Close", for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        upView.addSubview(cancelButton)
        self.view.addSubview(upView)
        
        bottomVIew.frame = CGRect(x:0,y:self.view.frame.size.height - 130,width: self.view.frame.size.width, height: 130)
        bottomVIew.backgroundColor = UIColor.black
        self.view.addSubview(bottomVIew)
    }
    
    func cardIOView(_ cardIOView: CardIOView!, didScanCard cardInfo: CardIOCreditCardInfo!) {
        print(cardInfo)
        if((cardInfo) != nil)
        {
            print(cardInfo.cardType.rawValue)
            let cardType = validateCardType(testCard: cardInfo.cardNumber)
            print(cardType)
            for i in 0..<aryCardDetails.count
            {
                let data = aryCardDetails.object(at: i) as! CardDetails
                if(data.name == cardType)
                {
                    isSelectIndex = i
                    isCardSelect = true
                    break
                }
            }
            txtCardNumber.text = cardInfo.cardNumber
            txtCardMonth.text = String(format:"%02lu/%lu\n",cardInfo.expiryMonth,cardInfo.expiryYear)
            txtCardMonth.text =  txtCardMonth.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if(txtCardMonth.text == "00/0")
            {
                txtCardMonth.text = ""
            }
            self.Coll_CardView.reloadData()
        }
        upView.removeFromSuperview()
        myCustomCard.removeFromSuperview()
        bottomVIew.removeFromSuperview()
    }
    
    @objc func cancelTapped(sender: UIButton!) {
        upView.removeFromSuperview()
        myCustomCard.removeFromSuperview()
        bottomVIew.removeFromSuperview()
    }
    
    func validateCardType(testCard: String) -> String {
        
        let regVisa = "^4[0-9]{12}(?:[0-9]{3})?$"
        let regMaster = "^5[1-5][0-9]{14}$"
        let regExpress = "^3[47][0-9]{13}$"
        let regDiners = "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        let regDiscover = "^6(?:011|5[0-9]{2})[0-9]{12}$"
        let regJCB = "^(?:2131|1800|35\\d{3})\\d{11}$"
        let regHipercard = "^(606282|3841)[0-9]{5,}$"
        let regElo = "^((((636368)|(438935)|(504175)|(451416)|(636297))[0-9]{0,10})|((5067)|(4576)|(4011))[0-9]{0,12})$"
        let regCartão_MercadoLivre = "^((530032)|(522499))"
        let regBoleto = ""
        
        let regVisaTest = NSPredicate(format: "SELF MATCHES %@", regVisa)
        let regMasterTest = NSPredicate(format: "SELF MATCHES %@", regMaster)
        let regExpressTest = NSPredicate(format: "SELF MATCHES %@", regExpress)
        let regDinersTest = NSPredicate(format: "SELF MATCHES %@", regDiners)
        let regDiscoverTest = NSPredicate(format: "SELF MATCHES %@", regDiscover)
        let regJCBTest = NSPredicate(format: "SELF MATCHES %@", regJCB)
        let regHipercardTest = NSPredicate(format: "SELF MATCHES %@", regHipercard)
        let regEloTest = NSPredicate(format: "SELF MATCHES %@", regElo)
        let regCartão_MercadoLivreTest = NSPredicate(format: "SELF MATCHES %@", regCartão_MercadoLivre)
        let regBoletoTest = NSPredicate(format: "SELF MATCHES %@", regBoleto)
        
        if regVisaTest.evaluate(with: testCard){
            return "Visa"
        }
        else if regMasterTest.evaluate(with: testCard){
            return "MasterCard"
        }
            
        else if regExpressTest.evaluate(with: testCard){
            return "American Express"
        }
            
        else if regDinersTest.evaluate(with: testCard){
            return "Diners"
        }
            
        else if regDiscoverTest.evaluate(with: testCard){
            return "Discover"
        }
            
        else if regJCBTest.evaluate(with: testCard){
            return "JCB"
        }
        
        else if regHipercardTest.evaluate(with: testCard)
        {
            return "Hipercard"
        }
        
        else if regEloTest.evaluate(with: testCard)
        {
            return "Elo"
        }
        
        else if regCartão_MercadoLivreTest.evaluate(with: testCard)
        {
            return "Cartão MercadoLivre"
        }
        
        else if regBoletoTest.evaluate(with: testCard)
        {
            return "Boleto"
        }
        return ""
        
    }
}

extension AddCreditCardVC : CardIOPaymentViewControllerDelegate{
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        print(cardInfo)
    }
    
    
    
    // Close ScanCard Screen
    public func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
//    // Using this delegate method, retrive card information
//    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
//        if let info = cardInfo {
//            /*let str = String(format: "Received card info.\n Cardholders Name: %@ \n Number: %@\n expiry: %02lu/%lu\n cvv: %@.,%@.",info.redactedCardNumber
//             , info.expiryMonth, info.expiryYear, info.cvv,info.cardNumber)*/
//            print(info.cardNumber)
//            print(info.expiryYear, info.expiryMonth)
//           // txtHolderName.text = ""//info.cardholderName
//
//            txtCardNumber.text = info.redactedCardNumber
//
//          //  txtExpireDate.text = String(format:"%02lu/%lu\n",info.expiryMonth,info.expiryYear)
//
//           // txtCVV.text = info.cvv
//
//            //    print(str)
//        }
//
//        paymentViewController.dismiss(animated: true, completion: nil)
//    }
}

extension Collection {
    public func chunk(n: IndexDistance) -> [SubSequence] {
        var res: [SubSequence] = []
        var i = startIndex
        var j: Index
        while i != endIndex {
            j = index(i, offsetBy: n, limitedBy: endIndex) ?? endIndex
            res.append(self[i..<j])
            i = j
        }
        return res
    }
}

extension String {
    func chunkFormatted(withChunkSize chunkSize: Int = 5,
                        withSeparator separator: Character = "-") -> String {
        return characters.filter { $0 != separator }.chunk(n: chunkSize)
            .map{ String($0) }.joined(separator: String(separator))
    }
}

extension String {
    func isValidCard(value: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: value, options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}

