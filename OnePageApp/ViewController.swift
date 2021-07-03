//
//  ViewController.swift
//  OnePageApp
//
//  Created by Apple Bagda on 25/05/21.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var txtBirthDate: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var segmentGenderSelection: UISegmentedControl!
    
    var lat = Double()
    var long = Double()
    
    var datePicker: UIDatePicker!
    var datePickerConstraints = [NSLayoutConstraint]()
    var blurEffectView: UIView!
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtBirthDate.addInputViewDatePicker(target: self, selector: #selector(doneButtonPressed))
        getLocation()
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
       }

    
    @objc func doneButtonPressed() {
        if let  datePicker = self.txtBirthDate.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            self.txtBirthDate.text = dateFormatter.string(from: datePicker.date)
            print("selected date is : \(String(describing: txtBirthDate.text))")
        }
        self.txtBirthDate.resignFirstResponder()
     }
    

    // for get user current location
    func getLocation(){
        let cityCoords = CLLocation(latitude: lat, longitude: long)
        getAdressName(coords: cityCoords)
    }
    
    
    
    
    @IBAction func btnSubmit(_ sender: Any) {
        
        if Validation.shared.validate(obj: self)
        {
            showMessage(title: NSLocalizedString("Success", comment: ""), message: "Info upload successfully.")
        }
        
    }
    

    @IBAction func genderSelection(_ sender: Any) {
        switch segmentGenderSelection.selectedSegmentIndex {
        case 0:
            print("Male")
            break
              
        case 1:
            print("Female")
            break
              
           default:
               break;
           }
    }
    
}

// for user location
extension ViewController : CLLocationManagerDelegate{

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        lat = locValue.latitude
        long = locValue.longitude
        getLocation()
        //        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }

    
    func getAdressName(coords: CLLocation) {

        CLGeocoder().reverseGeocodeLocation(coords) { (placemark, error) in
                if error != nil {
                    print("Hay un error")
                } else {

                    let place = placemark! as [CLPlacemark]
                    if place.count > 0 {
                        let place = placemark![0]
                        var adressString : String = ""
                        if place.thoroughfare != nil {
                            adressString = adressString + place.thoroughfare! + ", "
                        }
                        if place.subThoroughfare != nil {
                            adressString = adressString + place.subThoroughfare! + "\n"
                        }
                        if place.subLocality != nil{
                            adressString = adressString + place.subLocality! + ", "
                        }
                        if place.locality != nil {
                            adressString = adressString + place.locality! + ", "
                        }
                        if place.country != nil {
                            adressString = adressString + place.country!
                        }
                        if place.postalCode != nil {
                            adressString =  adressString + " (" + place.postalCode! + ")"
                        }
                         print(adressString)
                        self.txtAddress.text = adressString
                        self.locationManager.stopUpdatingLocation()
                    }
                }
            }
      }
}

