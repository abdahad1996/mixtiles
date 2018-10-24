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

protocol paymentTokenDelegate: class {
    func paymentToken(token: String, paymentid: String, cpf: String)
}

class AddCreditCardVC: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var Coll_CardView: UICollectionView!
    @IBOutlet weak var txtCardHolderName: HoshiTextField!
    @IBOutlet weak var txtCardNumber: HoshiTextField!
    @IBOutlet weak var txtCardMonth: HoshiTextField!
    @IBOutlet weak var txtSecurityCode: HoshiTextField!
    @IBOutlet weak var txtCPFNo: HoshiTextField!
    @IBOutlet weak var btnAdd: UIButton!
//    @IBOutlet weak var lblCPF: UILabel!
    
    @IBOutlet weak var cardValidationLabel: UILabel!
    @IBOutlet weak var cardTypeLabel: UILabel!
    
    @IBOutlet weak var view_HideforBoleto: UIView!
    @IBOutlet weak var constant_HeightforBoleto: NSLayoutConstraint!
    
    @IBOutlet weak var lblHeaderTitle: UILabel!
    
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
//    let dropDownList = DropDown()
    var payment_method_id = String()
    
    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?
    var creditCardValidator: CreditCardValidator!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtCardNumber.delegate = self
        txtCardMonth.delegate = self
        txtSecurityCode.delegate = self
        txtCPFNo.delegate = self
        DropDown.startListeningToKeyboard()
        
        // Do any additional setup after loading the view.
        creditCardValidator = CreditCardValidator()
        self.btnAdd.layer.cornerRadius = self.btnAdd.frame.size.height/2
        self.setLocalization()
        ApiGetPaymentMethods()

        txtCardNumber.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
        
        if defaults.value(forKey: keydictcreditcard) != nil{
            print(defaults.value(forKey: keydictcreditcard)!)
            let dictCard = defaults.value(forKey: keydictcreditcard) as! NSDictionary
            let cardHolder = dictCard.value(forKey: "cardholder") as! NSDictionary
            let identification = cardHolder.value(forKey: "identification") as! NSDictionary
            
            if let name = cardHolder.value(forKey: "name") as? String{
                self.txtCardHolderName.text = name
            }
            
            if let cardno = dictCard.value(forKey: "card_number") as? String{
                let finalcardno = cardno.pairs.joined(separator: " ")
                self.txtCardNumber.text = finalcardno
            }
            
            if let emonth = dictCard.value(forKey: "expiration_month") as? String, let eyear = dictCard.value(forKey: "expiration_year") as? String{
                self.txtCardMonth.text = emonth+eyear
            }
            
            if let SecurityCode = dictCard.value(forKey: "security_code") as? String {
                self.txtSecurityCode.text = SecurityCode
            }
        }
        
        if defaults.value(forKey: keyCardIndex) != nil{
            if let index = defaults.value(forKey: keyCardIndex) as? Int{
                
                let indexPath = IndexPath(item: index, section: 0)
                let cell = Coll_CardView.cellForItem(at: indexPath)
                cell?.layer.borderColor = UIColor.blue.cgColor
                isSelectIndex = index
                
                self.Coll_CardView.scrollToItem(at: indexPath, at: .left, animated: false)
                if index == 7 {
                    self.constant_HeightforBoleto.constant = 0
                    self.view_HideforBoleto.isHidden = true
                }
                else {
                    self.constant_HeightforBoleto.constant = 180
                    self.view_HideforBoleto.isHidden = false
                }
                
                let dictTemp = aryCardDetails.object(at: index) as! CardDetails
                print(dictTemp.name)
                payment_method_id = dictTemp.id
                SecurityCodeLen = dictTemp.length
                CardNumberLen = dictTemp.card_no_length
                patternStr = dictTemp.pattern
            }
        }
        
        if defaults.value(forKey: keycpfno) != nil{
            if let CPFNo = defaults.value(forKey: keycpfno) as? String{
                self.txtCPFNo.text = CPFNo
            }
        }
        self.txtCardHolderName.autocapitalizationType = .words
    }

    func setLocalization()
    {
        self.lblHeaderTitle.text = LocalizedLanguage(key: "lbl_title_add_credit_card", languageCode: lanCode)
        self.txtCardHolderName.placeholder = LocalizedLanguage(key: "txt_card_holder_name", languageCode: lanCode)
        self.txtCardNumber.placeholder = LocalizedLanguage(key: "txt_card_number", languageCode: lanCode)
        self.txtCardMonth.placeholder = LocalizedLanguage(key: "txt_mmyyyy", languageCode: lanCode)
        self.txtSecurityCode.placeholder = LocalizedLanguage(key: "txt_security_code", languageCode: lanCode)
        self.txtCPFNo.placeholder = LocalizedLanguage(key: "txt_cpf_number", languageCode: lanCode)
        self.btnAdd.setTitle(LocalizedLanguage(key: "btn_add", languageCode: lanCode), for: .normal)
    }
    @IBAction func CheckCardNumber(_ sender: UITextField) {
        if let number = sender.text {
            if number.isEmpty {
                self.cardValidationLabel.text = LocalizedLanguage(key: "alert_card_no", languageCode: lanCode)
                self.cardValidationLabel.textColor = UIColor.black
                
                self.cardTypeLabel.text = LocalizedLanguage(key: "alert_card_no", languageCode: lanCode)
                self.cardTypeLabel.textColor = UIColor.black
            } else {
                validateCardNumber(number: number)
                detectCardNumberType(number: number)
            }
        }
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
        
        if textField == self.txtCardNumber{
            if CardNumberLen != 0{
                
                previousTextFieldContent = textField.text;
                previousSelection = textField.selectedTextRange;
                return true
//                guard string.compactMap({ Int(String($0)) }).count ==
//                    string.count else { return false }
//
//                let text = textField.text ?? ""
//
//                if string.count == 0 {
//                    textField.text = String(text.dropLast()).chunkFormatted()
//                }
//                else {
//                    let newText = String((text + string)
//                        .filter({ $0 != " " }).prefix(Int(truncating: CardNumberLen)))
//                    textField.text = newText.chunkFormatted()
//                }
//                return false
//               return updatedText.count <= Int(truncating: CardNumberLen)
            }
            else{
                showAlert(titleStr: LocalizedLanguage(key: "alert_select_credit_card", languageCode: lanCode), msg: "")
            }
            
        }
        if textField == self.txtCardMonth{
            let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return checkExpirationDate(string: string, str: str)
        }
        
        if textField == self.txtSecurityCode{
            if SecurityCodeLen != 0{
                return updatedText.count <= Int(truncating: SecurityCodeLen)
            }else{
                showAlert(titleStr: LocalizedLanguage(key: "alert_select_credit_card", languageCode: lanCode), msg: "")
            }
        }
        if textField == self.txtCPFNo{
            let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return checkCPFNumberFormat(string: string, str: str)
        }
        
        /*if textField == self.txtCPFNo{
            return updatedText.count <= Int(truncating: CPFMaxLimit)
        }else{
            showAlert(titleStr: "Select CPF", msg: "")
        }*/
        
       return true
    }
    
    func checkExpirationDate(string: String?, str: String?) -> Bool{
        if string == ""{ //BackSpace
            return true
        }else if str!.count == 3{
            self.txtCardMonth.text = self.txtCardMonth.text! + "/"
        }else if str!.count > 7{
            return false
        }
        return true
    }
    
    func checkCPFNumberFormat(string: String?, str: String?) -> Bool{
        if string == ""{ //BackSpace
            return true
        }else if str!.count == 4{
            self.txtCPFNo.text = self.txtCPFNo.text! + "."
        }else if str!.count == 8{
            self.txtCPFNo.text = self.txtCPFNo.text! + "."
        }else if str!.count == 12{
            self.txtCPFNo.text = self.txtCPFNo.text! + "-"
        }else if str!.count > 14{
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
        // Mapping of card prefix to pattern is taken from
        // https://baymard.com/checkout-usability/credit-card-patterns
        
        // UATP cards have 4-5-6 (XXXX-XXXXX-XXXXXX) format
// dipak       let is456 = string.hasPrefix("1")
        
        // These prefixes reliably indicate either a 4-6-5 or 4-6-4 card. We treat all these
        // as 4-6-5-4 to err on the side of always letting the user type more digits.
        let is465 = ["34", "37"].contains { string.hasPrefix($0) }
        
        // In all other cases, assume 4-4-4-4-3.
        // This won't always be correct; for instance, Maestro has 4-4-5 cards according
        // to https://baymard.com/checkout-usability/credit-card-patterns, but I don't
        // know what prefixes identify particular formats.
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
    
    @IBAction func Click_backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func isNumberValidation(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = patternStr
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @IBAction func Click_addBtn(_ sender: UIButton) {
        //by original
        let success = BooleanValidator().validate(cpf: self.txtCPFNo.text!)
        print(success)
        if payment_method_id == "bolbradesco" {
            if self.txtCPFNo.text!.isEmpty{
                showAlert(titleStr: LocalizedLanguage(key: "alert_cpf_no", languageCode: lanCode), msg: "")
            }else if success == false{
                showAlert(titleStr: LocalizedLanguage(key: "alert_cpf_no_invalid", languageCode: lanCode), msg: "")
            }
            else {
                defaults.set(self.payment_method_id, forKey: keyPaymentMethod)
                defaults.set(isSelectIndex, forKey: keyCardIndex)
                defaults.set(self.txtCPFNo.text!, forKey: keycpfno)
                self.delegate?.paymentToken(token: "", paymentid: "", cpf: self.txtCPFNo.text!)
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            if self.txtCardHolderName.text!.isEmpty{
                showAlert(titleStr: LocalizedLanguage(key: "alert_card_holder_name", languageCode: lanCode), msg: "")
            }else if txtCardNumber.text!.isEmpty{
                showAlert(titleStr: LocalizedLanguage(key: "alert_card_no", languageCode: lanCode), msg: "")
            }else if isNumberValidation(testStr: self.txtCardNumber.text!){
                showAlert(titleStr: LocalizedLanguage(key: "alert_card_no_invalid", languageCode: lanCode), msg: "")
            }else if self.txtCardMonth.text!.isEmpty || self.txtCardMonth.text!.count < 2 {
                showAlert(titleStr: LocalizedLanguage(key: "alert_mmyyyy", languageCode: lanCode), msg: "")
            }else if self.txtCardMonth.text!.count < 7 {
                showAlert(titleStr: LocalizedLanguage(key: "alert_mmyyyy", languageCode: lanCode), msg: "")
            }else if self.txtSecurityCode.text!.isEmpty{
                showAlert(titleStr: LocalizedLanguage(key: "alert_security_code", languageCode: lanCode), msg: "")
            }else if self.txtSecurityCode.text!.count < 3 {
                showAlert(titleStr: LocalizedLanguage(key: "alert_security_code_invalid", languageCode: lanCode), msg: "")
            }else if self.txtCPFNo.text!.isEmpty{
                showAlert(titleStr: LocalizedLanguage(key: "alert_cpf_no", languageCode: lanCode), msg: "")
            }else if success == false{
                showAlert(titleStr: LocalizedLanguage(key: "alert_cpf_no_invalid", languageCode: lanCode), msg: "")
            }else {
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
                
                Dictidentification.setValue("\(self.txtCPFNo.text!)", forKey: "number")
                dictCardHolder.setValue(Dictidentification, forKey: "identification")
                dictCardHolder.setValue("\(self.txtCardHolderName.text!)", forKey: "name")
                
                print(dictTemp)
                
                defaults.set(dictTemp, forKey: keydictcreditcard)
                defaults.set(isSelectIndex, forKey: keyCardIndex)
                defaults.set(self.txtCPFNo.text!, forKey: keycpfno)
                
                if Reachability.isConnectedToNetwork(){
                    ApiPostCardTokens(dict: dictTemp)
                }
                else {
                    showAlert(titleStr: alertNetwork, msg: "")
                }
            }
        }
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
                        self.aryCardDetails.add(carddetail)
                    }
                    if Reachability.isConnectedToNetwork(){
                        self.ApiGetIdentiType()
                    }else{
                        showAlert(titleStr: alertNetwork, msg: "")
                    }
                    DispatchQueue.main.async(execute: {
                        self.Coll_CardView.reloadData()
                    })
                }
            } catch {
                // handle error
            }
        }
        
       /* self.showHUD()
        Alamofire.request(Mpayment_methods, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            print(response.error as Any)
            print(response.result.value as Any)
            self.hideHUD()
            
            if response.error != nil{
                self.showAlert(titleStr: alertMissing, msg: "")
                return
            }
            
            if response.result.value != nil{
                let aryTemp = response.result.value as! NSArray
                let AryRList = NSMutableArray(array: aryTemp)
                for i in 0..<AryRList.count
                {
                     let carddetail = CardDetails().initwithdictionary(dict: AryRList[i] as! [String: Any])
                    self.aryCardDetails.add(carddetail)
                }
                self.ApiGetIdentiType()
                DispatchQueue.main.async(execute: {
                    self.Coll_CardView.reloadData()
                })
            }
        }
         */
    }
    
    func ApiGetIdentiType()
    {
        self.showHUD()
        Alamofire.request(Midentification_types, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            self.hideHUD()
            if response.error != nil{
                self.showAlert(titleStr: alertMissing, msg: "")
                return
            }
            
            if response.result.value != nil{
                let aryTemp = response.result.value as! NSArray
                let AryList = NSMutableArray(array: aryTemp)
                for i in 0..<AryList.count
                {
                    let identificationType = IdentificationType().initwithdictionary(dict: AryList[i] as! [String: Any])
                    self.aryIdentiType.add(identificationType)
//                    self.setupChooseDropDown()
                }
            }
        }
    }
    
    func ApiPostCardTokens(dict : NSDictionary)
    {
        self.showHUD()
        Alamofire.request(Mcard_tokens, method: .post, parameters: (dict as! [String:Any]), encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            self.hideHUD()
            if response.error != nil{
                self.showAlert(titleStr: alertMissing, msg: "")
                return
            }
            
            if response.result.value != nil{
                let ResponseDict = response.result.value as! NSDictionary
                if let Status = ResponseDict.value(forKey: "status") as? String{
                    if Status == "active"{
                        if let id = ResponseDict.value(forKey: "id") as? String{
                            print(id)
                            self.delegate?.paymentToken(token: id, paymentid: self.payment_method_id, cpf: "")
                            defaults.set(id, forKey: keyTokenCreditCard)
                            defaults.set(self.payment_method_id, forKey: keyPaymentMethod)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else{
                        print("error")
                    }
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
        
        if indexPath.row == isSelectIndex{
            Cell.layer.borderColor = UIColor.blue.cgColor
            isSelectIndex = indexPath.row
        }
        return Cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:
        IndexPath) {
        let dictTemp = aryCardDetails.object(at: indexPath.row) as! CardDetails
        print(dictTemp.name)
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

