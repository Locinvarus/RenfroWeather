//
//  AppUtilities.swift
//  RenfroWeather
//
//  Created by Roger Renfro on 3/2/18.
//  Copyright © 2018 Roger Renfro. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

class AppHelper: NSObject {
    
    // create class properties
    public var nightDay: String = ""
    public let weatherUndergroundURL = "https://api.wunderground.com/api/"
    public var weatherUndergroundAPIKey = ""
    public let weatherUndergroundWeatherEndPoint = "/conditions/q/pws:KWAVANCO374.json"
    public let weatherUndergroundAstronomyEndPoint = "/astronomy/q/washington/vancouver.json"
    
    // func to display alert box from anywhere in the app
    func showAlert(vc : UIViewController, titleString : String , messageString: String) ->() {
        let alertView = UIAlertController.init(title: titleString, message: messageString, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .cancel) { (alert) in
            vc.dismiss(animated: true, completion: nil)
        }
        alertView.addAction(alertAction)
        vc.present(alertView, animated: true, completion: nil)
    }
    
    // function to read app.plist file
    func readAppPlist(key : String) -> String {
        var resourceFileDictionary: NSDictionary?
        var returnValue: String = ""
        
        //Load content of App.plist into resourceFileDictionary dictionary
        if let path = Bundle.main.path(forResource: "App", ofType: "plist") {
            resourceFileDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if let resourceFileDictionaryContent = resourceFileDictionary {
            
            // Get value from App.plist that matches the key parameter
            if resourceFileDictionaryContent.object(forKey: key) != nil {
                returnValue = resourceFileDictionaryContent.object(forKey: key)! as! String
            }
            
        }
        return returnValue
    }
    
    // set the Weather Underground API Key
    func setAPIKey() {
        weatherUndergroundAPIKey = readAppPlist(key: "API_KEY")
    }
    
    // function to determine if it's night or day
    func nightOrDay() {

        // get current date to make sunrise and sunset date/times
        let currentDate = DateInRegion()
        let currentDate2 = currentDate.string(custom: "yyyy-MM-dd")
        //print(currentDate2)
        
        // get current date and time for comparison
        let currentDateTime = DateInRegion()
        let currentDateTime2 = currentDateTime.string(custom: "yyyy-MM-dd HH:mm")
        //print(currentDateTime2)
        
        // Construct URL
        let baseURL = URL(string: weatherUndergroundURL + weatherUndergroundAPIKey + weatherUndergroundAstronomyEndPoint)
        
        let task = URLSession.shared.dataTask(with: baseURL!) { (data,
            response, error) in
            if error != nil {
                //self.messageBox.showAlert(vc: self, titleString: "URLSession error", messageString: error!.localizedDescription)
            }
            let jsonDecoder = JSONDecoder()
            guard let data = data else {
                //print(self.stationFullName.text = "Error")
                return
            }
            do {
                let astro = try jsonDecoder.decode(WeatherDataModel.AstronomyJSONStruct.self, from: data)
                //return completionHandler(.success())
                
                DispatchQueue.main.async {
                    //make sunrise and sunset date/times
                    let sunriseTime = currentDate2 + " " + String(format: "%02d", Int(astro.sun_phase.sunrise.hour)!) + ":" + String(format: "%02d", Int(astro.sun_phase.sunrise.minute)!)
                    let sunsetTime = currentDate2 + " " + String(format: "%02d", Int(astro.sun_phase.sunset.hour)!) + ":" + String(format: "%02d", Int(astro.sun_phase.sunset.minute)!)
                    //print(sunriseTime)
                    //print(sunsetTime)
                    
                    //test for daytime or nighttime
                    if currentDateTime2 > sunriseTime  {
                        if currentDateTime2 < sunsetTime {
                            self.nightDay = "Day"
                        }
                        else {
                            self.nightDay = "Night"
                        }
                    }
                }

                //print(self.nightDay)
                
            } catch DecodingError.keyNotFound(let key, let context) {
//                print("Missing key:\(key)")
//                print("Debug description: \(context.debugDescription)")
            } catch DecodingError.valueNotFound(let key, let context) {
//                print("Value not found:\(key)")
//                print("Debug description: \(context.debugDescription)")
            } catch DecodingError.typeMismatch(let key, let context) {
//                print("Type mismatch:\(key)")
//                print("Debug description: \(context.debugDescription)")
            } catch {
//                print("Debug description: \(context.debugDescription)")
            }
        }
        task.resume()
    }
}
