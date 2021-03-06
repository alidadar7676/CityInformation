//
//  ViewController.swift
//  CityInfo
//
//  Created by Ali Soume`e on 6/4/1395 AP.
//  Copyright © 1395 Ali-Soume. All rights reserved.
//

import UIKit
import PopupDialog

class ViewController: UIViewController {

    
    @IBOutlet weak var enterYourLocationLb: UILabel!
    @IBOutlet weak var getCityNameTF: UITextField!
    @IBOutlet weak var submitBt: UIButton!
    var json: Dictionary<String, AnyObject>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCityNameTF.text = ""
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    
    @IBAction func checkCityName(sender: UIButton) {
        let urlString: String = "http://api.openweathermap.org/data/2.5/weather?q=\(getCityNameTF.text!)&APPID=e3a22a7b27e1b81c1bb76e7e2c5efd70"
        let url = NSURL(string: urlString)!
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let data = data {
                do{
                    self.json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! Dictionary<String, AnyObject>
                    
                    if self.json["cod"] as? Int == 200{
                        dispatch_async(dispatch_get_main_queue()) {
                            self.performSegueWithIdentifier("ShowMainTabBar", sender: nil)
                        }
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue()) {
                            self.editPopup("Error", message: "Your entrance city is not available", bt1: "OK")
                            self.getCityNameTF.text = ""
                        }
                    }
                }
                catch{
                    
                }
            }
            else{
                print(error)
            }
        }
        task.resume()
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMainTabBar"{
            let temp = segue.destinationViewController as! UITabBarController
            let infoItem = temp.viewControllers![0] as! InfoItemVC
            let wikiItem = temp.viewControllers![1] as! WikiItemVC
            let mapItem = temp.viewControllers![2] as! MapVC
            
            if let lon = self.json["coord"]!["lon"] as? Double
                , let lat = self.json["coord"]!["lat"] as? Double {
                mapItem.editLocation(lon, lat: lat)
            }
            
            if let name = self.json["name"] {
                wikiItem.urlString = "https://en.wikipedia.org/wiki/\(name)"
            }
            
            if let temp = self.json["main"]!["temp"] as? Int
                , let pressure = self.json["main"]!["pressure"] as? Int
                , let humidity = self.json["main"]!["humidity"] as? Int
                , let lon = self.json["coord"]!["lon"] as? Int
                , let lat = self.json["coord"]!["lat"] as? Int
                , let desc = self.json["weather"]![0]!["description"] as? String {
                infoItem.edit(temp, pressure: pressure, humidity: humidity, lon: lon, lat: lat, desc: desc)
            }
        }
    }
    

    func editPopup(title: String , message: String, bt1: String) {
        let popup = PopupDialog(title: title, message: message)
        let button1 = DefaultButton(title: bt1, action: .None)
        popup.addButton(button1)
        self.presentViewController(popup, animated: true, completion: nil)
    }
}

















