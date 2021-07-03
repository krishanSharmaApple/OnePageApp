//
//  SwAlert.swift
//  OnePageApp
//
//  Created by Apple Bagda on 26/05/21.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public typealias CompletionHandler = (_ resultObject: AnyObject?) -> Void

private class AlertManager {
    
    static var sharedInstance = AlertManager()
    
    var window : UIWindow = UIWindow(frame: UIScreen.main.bounds)
    lazy var parentController : UIViewController = {
        var parentController = UIViewController()
        parentController.view.backgroundColor = UIColor.clear
        
        if UIDevice.isiOS8orLater() {
            self.window.windowLevel = UIWindow.Level.alert
            self.window.rootViewController = parentController
        }
        
        return parentController
    }()
    
    var alertQueue : [SwAlert] = []
    var showingAlertView : SwAlert?
}

private class AlertInfo {
    var title : String = ""
    var placeholder : String = ""
    var completion : CompletionHandler?
    
    class func generate(_ title: String, placeholder: String?, completion: CompletionHandler?) -> AlertInfo {
        let alertInfo = AlertInfo()
        alertInfo.title = title
        if placeholder != nil {
            alertInfo.placeholder = placeholder!
        }
        alertInfo.completion = completion
        
        return alertInfo
    }
}

open class SwAlert: NSObject, UIAlertViewDelegate {
    fileprivate var title : String = ""
    fileprivate var message : String = ""
    fileprivate var cancelInfo : AlertInfo?
    fileprivate var otherButtonHandlers : [AlertInfo] = []
    fileprivate var textFieldInfo : [AlertInfo] = []
    
    // MARK: - Class Methods
    
    class func showNoActionAlert(_ title: String, message: String, buttonTitle: String) {
        let alert = SwAlert()
        alert.title = title
        alert.message = message
        alert.cancelInfo = AlertInfo.generate(buttonTitle, placeholder: nil, completion: nil)
        alert.show()
    }
    
    class func showOneActionAlert(_ title: String, message: String, buttonTitle: String, completion: CompletionHandler?) {
        let alert = SwAlert()
        alert.title = title
        alert.message = message
        alert.cancelInfo = AlertInfo.generate(buttonTitle, placeholder: nil, completion: completion)
        alert.show()
    }
    
    class func generate(_ title: String, message: String) -> SwAlert {
        let alert = SwAlert()
        alert.title = title
        alert.message = message
        return alert
    }
    
    // MARK: - Instance Methods
    
    func setCancelAction(_ buttonTitle: String, completion: CompletionHandler?) {
        self.cancelInfo = AlertInfo.generate(buttonTitle, placeholder: nil, completion: completion)
    }
    
    func addAction(_ buttonTitle: String, completion: CompletionHandler?) {
        let alertInfo = AlertInfo.generate(buttonTitle, placeholder: nil, completion: completion)
        self.otherButtonHandlers.append(alertInfo)
    }
    
    func addTextField(_ title: String, placeholder: String?) {
        let alertInfo = AlertInfo.generate(title, placeholder: placeholder, completion: nil)
        if UIDevice.isiOS8orLater() {
            self.textFieldInfo.append(alertInfo)
        } else {
            if self.textFieldInfo.count >= 2 {
                assert(true, "iOS7 is 2 textField max")
            } else {
                self.textFieldInfo.append(alertInfo)
            }
        }
    }
    
    func show() {
        if UIDevice.isiOS8orLater() {
            self.showAlertController()
        } else {
            self.showAlertController()
        }
    }
    
    // MARK: - Private
    
    fileprivate class func dismiss() {
        if UIDevice.isiOS8orLater() {
            SwAlert.dismissAlertController()
        } else {
            SwAlert.dismissAlertController()
        }
    }
    
    // MARK: - UIAlertController (iOS 8 or later)
    
    fileprivate func showAlertController() {
        if AlertManager.sharedInstance.parentController.presentedViewController != nil {
           AlertManager.sharedInstance.alertQueue.append(self)
            return
        }
        
        if #available(iOS 8.0, *) {
            
            let alertController = UIAlertController(title: self.title, message: self.message, preferredStyle: .alert)
            
            for alertInfo in self.textFieldInfo {
                alertController.addTextField(configurationHandler: { (textField) -> Void in
                    textField.placeholder = alertInfo.placeholder
                    textField.text = alertInfo.title
                })
            }
            
            for alertInfo in self.otherButtonHandlers {
                let handler = alertInfo.completion
                let action = UIAlertAction(title: alertInfo.title, style: .default, handler: { (action) -> Void in
                    if let _handler = handler {
                        if alertController.textFields?.count > 0 {
                            _handler(alertController.textFields as AnyObject?)
                        } else {
                            _handler(action)
                        }
                    }
                    SwAlert.dismiss()
                })
                alertController.addAction(action)
            }
            
            if self.cancelInfo != nil {
                let handler = self.cancelInfo!.completion
                let action = UIAlertAction(title: self.cancelInfo!.title, style: .cancel, handler: { (action) -> Void in
                    if let _handler = handler {
                        _handler(action)
                    }
                    SwAlert.dismiss()
                })
                alertController.addAction(action)
            } else if self.otherButtonHandlers.count == 0 {
                if self.textFieldInfo.count > 0 {
                    let action = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                        SwAlert.dismiss()
                    })
                    alertController.addAction(action)
                } else {
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                        SwAlert.dismiss()
                    })
                    alertController.addAction(action)
                }
            }
            
            if AlertManager.sharedInstance.window.isKeyWindow == false {
                AlertManager.sharedInstance.window.alpha = 1.0
                AlertManager.sharedInstance.window.makeKeyAndVisible()
            }
            
            AlertManager.sharedInstance.parentController.present(alertController, animated: true, completion: nil)
            
        } else {
            
        }
        
    }
    
    fileprivate class func dismissAlertController() {
        if AlertManager.sharedInstance.alertQueue.count > 0 {
            let alert = AlertManager.sharedInstance.alertQueue[0]
            AlertManager.sharedInstance.alertQueue.remove(at: 0)
            alert.show()
        } else {
            AlertManager.sharedInstance.window.alpha = 0.0
            let mainWindow = UIApplication.shared.delegate?.window
            mainWindow!!.makeKeyAndVisible()
        }
    }
    
    
    fileprivate class func dismissAlertView() {
         AlertManager.sharedInstance.showingAlertView = nil
        
        if AlertManager.sharedInstance.alertQueue.count > 0 {
            let alert = AlertManager.sharedInstance.alertQueue[0]
            AlertManager.sharedInstance.alertQueue.remove(at: 0)
            alert.show()
        }
    }
    
}

// MARK: - UIDevice Extension

public extension UIDevice {
    
    class func iosVersion() -> Float {
        let versionString =  UIDevice.current.systemVersion
        return NSString(string: versionString).floatValue
    }
    
    class func isiOS8orLater() ->Bool {
        let version = UIDevice.iosVersion()
        
        if version >= 8.0 {
            return true
        }
        return false
    }
}
