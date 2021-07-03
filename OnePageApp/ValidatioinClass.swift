//
//  ValidatioinClass.swift
//  OnePageApp
//
//  Created by Apple Bagda on 26/05/21.
//

import Foundation
import UIKit

class Validation {
    static let shared : Validation = {
        let instance = Validation()
        return instance
    }()
    
    func isTextFieldBlank(textField : UITextField) -> Bool
    {
        return (textField.text!.isEmpty)
    }
    
    
    func isTextViewBlank(textView : UITextField) -> Bool
    {
        return (textView.text!.isEmpty)
    }
    
    
    //check email addres
      func isValidEmail(email: String) -> Bool {
          let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
          return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
      }
      
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            if results.count == 0{
                returnValue = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        return  returnValue
    }
    
    func isValidPhone(phone: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phone)
    }
    
       func validate(obj:ViewController) -> Bool{
        
        if isTextFieldBlank(textField: obj.txtEmail){
               obj.showMessage(title: NSLocalizedString("Error!", comment: ""), message: "Please fill the email address.")
               return false
        }else if isValidEmailAddress(emailAddressString: obj.txtMobileNumber.text ?? ""){
            obj.showMessage(title: NSLocalizedString("Error!", comment: ""), message: "Please fill the valid email address.")
            return false
        }else if isTextFieldBlank(textField: obj.txtMobileNumber){
            obj.showMessage(title: NSLocalizedString("Error!", comment: ""), message: "Please fill the mobile number.")
            return false
        }else if isTextFieldBlank(textField: obj.txtBirthDate){
               obj.showMessage(title: NSLocalizedString("Error!", comment: ""), message: "Please fill the Birth date.")
               return false
           }else{
               return true
           }
       }
}
