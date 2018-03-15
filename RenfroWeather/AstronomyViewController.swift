//
//  AstronomyViewController.swift
//  RenfroWeather
//
//  Created by Roger Renfro on 3/2/18.
//  Copyright © 2018 Roger Renfro. All rights reserved.
//

import UIKit
import SwiftDate
import SwiftIcons

class AstronomyViewController: UIViewController {

    @IBOutlet weak var stationSunrise: UILabel!
    @IBOutlet weak var stationSunset: UILabel!
    @IBOutlet weak var stationMoonrise: UILabel!
    @IBOutlet weak var stationMoonset: UILabel!
    @IBOutlet weak var stationPercentIlluminated: UILabel!
    @IBOutlet weak var stationAgeOfMoon: UILabel!
    @IBOutlet weak var stationPhaseOfMoon: UILabel!
    @IBOutlet weak var stationMoon: UILabel!
    @IBOutlet weak var stationMoonImage: UIImageView!
    
    let appHelper = AppHelper()
    
    var astro: WeatherDataModel.AstronomyJSONStruct!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup gesture recognizers
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Do any additional setup after loading the view.
        updateAstronomy()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                tabBarController?.selectedIndex = 3
            case UISwipeGestureRecognizerDirection.left:
                tabBarController?.selectedIndex = 0
            default:
                break
            }
        }
    }
    
    func makeTime(hour: String, minute: String) -> String {
        // format hour and minute strings into time formatted string, i.e. 12 and 15 -> 12:15
        var returnValue: String = ""
        
        if hour == "" || minute == "" {
            returnValue = "Missing"
        } else {
            returnValue = String(format: "%02d", Int(hour)!) + ":" + String(format: "%02d", Int(minute)!)
        }
        return returnValue
    }
    
    func updateAstronomy() {
        //completionHandler:@escaping PWSResultCompletion
        
        // Construct URL
        let baseURL = URL(string: appHelper.weatherUndergroundURL + appHelper.weatherUndergroundAPIKey + appHelper.weatherUndergroundAstronomyEndPoint)
        
        let task = URLSession.shared.dataTask(with: baseURL!) { (data,
            response, error) in
            if error != nil {
                self.appHelper.showAlert(vc: self, titleString: "URLSession error", messageString: error!.localizedDescription)
            }
            let jsonDecoder = JSONDecoder()
            guard let data = data else {
                return
            }
            do {
                let astro = try jsonDecoder.decode(WeatherDataModel.AstronomyJSONStruct.self, from: data)
                //return completionHandler(.success())
                
                DispatchQueue.main.async {
                    self.stationSunrise.text = self.makeTime(hour: astro.sun_phase.sunrise.hour, minute: astro.sun_phase.sunrise.minute)
                    self.stationSunset.text = self.makeTime(hour: astro.sun_phase.sunset.hour, minute: astro.sun_phase.sunset.minute)
                    self.stationMoonrise.text = self.makeTime(hour: astro.moon_phase.moonrise.hour, minute: astro.moon_phase.moonrise.minute)
                    self.stationMoonset.text = self.makeTime(hour: astro.moon_phase.moonset.hour, minute: astro.moon_phase.moonset.minute)
                    self.stationPercentIlluminated.text = String("\(astro.moon_phase.percentIlluminated) %")
                    self.stationAgeOfMoon.text = String("\(astro.moon_phase.ageOfMoon) days")
                    self.stationPhaseOfMoon.text = astro.moon_phase.phaseofMoon
                    
                    switch astro.moon_phase.phaseofMoon {
                        case "New Moon":
                            self.stationMoonImage.image = UIImage(named: "Astronomy/NewMoon.png")
                        case "Waxing Crescent":
                            self.stationMoonImage.image = UIImage(named: "Astronomy/WaxingCrescent.png")
                        case "First Quarter":
                            self.stationMoonImage.image = UIImage(named: "Astronomy/FirstQuarter.png")
                        case "Waxing Gibbous":
                            self.stationMoonImage.image = UIImage(named: "Astronomy/WaxingGibbous.png")
                        case "Full Moon":
                            self.stationMoonImage.image = UIImage(named: "Astronomy/FullMoon.png")
                        case "Waning Gibbous":
                            self.stationMoonImage.image = UIImage(named: "Astronomy/WaningGibbous.png")
                        case "Last Quarter":
                            self.stationMoonImage.image = UIImage(named: "Astronomy/LastQuarter.png")
                        case "Waning Crescent":
                            self.stationMoonImage.image = UIImage(named: "Astronomy/WaningCrescent.png")
                        default:
                            self.stationMoonImage.image = UIImage(named: "Astronomy/NewMoon.png")
                    }
                }
            } catch DecodingError.keyNotFound(let context) {
                self.appHelper.showAlert(vc: self, titleString: "Missing key", messageString: String(describing: context))
            } catch DecodingError.valueNotFound(let context) {
                self.appHelper.showAlert(vc: self, titleString: "Value not found", messageString: String(describing: context))
            } catch DecodingError.typeMismatch(let context) {
                //                print("Type mismatch:\(key)")
                //                print("Debug description: \(context.debugDescription)")
                self.appHelper.showAlert(vc: self, titleString: "Type mismatch", messageString: String(describing: context))
            } catch {
                self.appHelper.showAlert(vc: self, titleString: "Unable to fetch astronomy", messageString: error.localizedDescription)
            }
        }
        task.resume()
    }

}
