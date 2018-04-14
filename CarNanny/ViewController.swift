//
//  ViewController.swift
//  Jude's Amazing Project
//
//  Created by Fernando on 2/9/18.
//  Copyright © 2018 Fernando. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

class ViewController: UIViewController,UNUserNotificationCenterDelegate,CLLocationManagerDelegate ,UITextFieldDelegate {
    @IBOutlet weak var lattitude: UITextField!
    @IBOutlet weak var logittude: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var timeTextField: UITextField!
    var isGrantedAccess = false
    let locationManager = CLLocationManager()
    var locationValue: CLLocation?
    var destination: CLLocation?
    var notificationSent = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapRecognizer)
        lattitude.delegate = self
        logittude.delegate = self
        lattitude.tag = 1
        logittude.tag = 2
        //Location Persmission
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        //Update Location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        }
        
        //Create Local Notification
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound])
        {(granted, error) in
            if granted {
                print("granted!")
            } else {
                print("NOT granted")
            }
            self.isGrantedAccess = granted
        }
        
        //Local Notification has a stop Button
        let stopAction = UNNotificationAction(identifier: "stop.action", title: "Stop", options: [])
        let timerCategory = UNNotificationCategory(identifier: "timer.category", actions: [stopAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([timerCategory])
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func handleTap(){
        logittude.endEditing(true)
        lattitude.endEditing(true)
        destination = CLLocation(latitude: CLLocationDegrees(exactly: Double(lattitude.text!)!)!, longitude: CLLocationDegrees(exactly: Double(logittude.text!)!)!)
        //print("Destination: \(destination?.longitude) \(destination?.latitude)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last != nil {
            if(lattitude.text != nil && logittude.text != nil){
                if let destinationValue = destination {
                    label.text = String(round((locations.last?.distance(from: destinationValue))!))
                    if round((locations.last?.distance(from: destinationValue))!) > 1000{
                        if !notificationSent {
                            if isGrantedAccess{
                                
                                let content = UNMutableNotificationContent()
                                content.title = "Timer Done"
                                content.body = "locations = \(locationValue!.coordinate.latitude) \(String(describing: locationValue!.coordinate.longitude))"
                                content.sound = UNNotificationSound.default()
                                content.categoryIdentifier = "timer.category"
                                
                                if let time = timeTextField.text {
                                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(time)!, repeats: false)
                                    let request = UNNotificationRequest(identifier: "timer.request", content: content, trigger: trigger)
                                    UNUserNotificationCenter.current().add(request) { (error) in
                                        if let error = error{
                                            print("Error posting notification:\(error.localizedDescription)")
                                        }
                                    }
                                    notificationSent = true
                                }
                                
                                print("done")
                            }
                        }
                    }
                }
                
                locationValue = locations.last
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Youpressedme(_ sender: UIButton) {
        print("You pressed me")
        
        // Location Stuff
        
        self.locationManager.startUpdatingLocation()
        // Create the alert controller
        
        
        //Local Okay or Close alerts
        
        let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.default) {
            UIAlertAction in
            print("OK Pressed")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            print("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        //self.present(alertController, animated: true, completion: nil)
        
        
        //Add local notification
        if isGrantedAccess{
            
            let content = UNMutableNotificationContent()
            content.title = "Timer Done"
            content.body = "locations = \(locationValue!.coordinate.latitude) \(String(describing: locationValue!.coordinate.longitude))"
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "timer.category"
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 0.001, repeats: false)
            
            let request = UNNotificationRequest(identifier: "timer.request", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error{
                    print("Error posting notification:\(error.localizedDescription)")
                }
            }
            print("done")
        }
    }
    
    
    // Delegates for Local Notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound, .badge])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.tag == 1){
            print("Lattitude updated")
        }
        
        else{
            print("Logittude done")
        }
    }
}


