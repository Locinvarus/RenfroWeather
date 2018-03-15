//
//  ViewController.swift
//  RenfroWeather
//
//  Created by Roger Renfro on 2/18/18.
//  Copyright © 2018 Roger Renfro. All rights reserved.
//

import UIKit
import SwiftIcons

fileprivate var foregroundNotification: NSObjectProtocol!

//typealias PWSResultCompletion = (_ result: Any) -> void

class SurfaceViewController: UIViewController {

    @IBOutlet weak var stationFullName: UILabel!
    @IBOutlet weak var stationDewpoint: UILabel!
    @IBOutlet weak var stationHumidity: UILabel!
    @IBOutlet weak var stationPressure: UILabel!
    @IBOutlet weak var stationObservationTime: UILabel!
    @IBOutlet weak var stationWind: UILabel!
    @IBOutlet weak var stationWindSpeed: UILabel!
    @IBOutlet weak var stationWindGust: UILabel!
    @IBOutlet weak var stationWeather: UILabel!
    @IBOutlet weak var stationPrecip1hr: UILabel!
    @IBOutlet weak var stationPrecipToday: UILabel!
    @IBOutlet weak var stationWallpaper: UIImageView!
    @IBOutlet weak var stationTemperature: UILabel!
    @IBOutlet weak var stationWeatherIcon: UIImageView!
    @IBOutlet weak var stationNightDay: UILabel!

    @IBAction func buttonUpdate(_ sender: Any) {
        updateWeather()
    }
    
    // create instance of apphelper class
    let appHelper = AppHelper()
    
    // create instance of WeatherJSONStruct
    var pws: WeatherDataModel.WeatherJSONStruct!
    
    // MARK: viewDidLoad
    // **********************************************************************************
    //
    // **********************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appHelper.setAPIKey()
        
        //setenv("CFNETWORK_DIAGNOSTICS", "3", 1);
    
        // setup gesture recognizers
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
        // set the nightDay property of the nightOrDay class
        self.appHelper.nightOrDay()
        
        updateWeather()
        
        // code to be notifed when app returns to foregound from sleep so we can refresh the data
        foregroundNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            [unowned self] notification in
            
            // do whatever you want when the app is brought back to the foreground
            self.updateWeather()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                tabBarController?.selectedIndex = 4
            case UISwipeGestureRecognizerDirection.left:
                tabBarController?.selectedIndex = 1
            case UISwipeGestureRecognizerDirection.down:
                updateWeather()
            default:
                break
            }
        }
    }
    
    // MARK: updateWeather
    // **********************************************************************************
    //
    // **********************************************************************************
    
    func updateWeather() {
        //completionHandler:@escaping PWSResultCompletion
        
        // Construct URL
        let baseURL = URL(string: appHelper.weatherUndergroundURL + appHelper.weatherUndergroundAPIKey + appHelper.weatherUndergroundWeatherEndPoint)

        let task = URLSession.shared.dataTask(with: baseURL!) { (data,
            response, error) in
            if error != nil {
                self.appHelper.showAlert(vc: self, titleString: "URLSession error", messageString: (error?.localizedDescription)!)
            }
            let jsonDecoder = JSONDecoder()
            guard let data = data else {
                return
            }
            do {
                let pws = try jsonDecoder.decode(WeatherDataModel.WeatherJSONStruct.self, from: data)
                //return completionHandler(.success())

                DispatchQueue.main.async {
                    self.stationFullName.text = pws.currentObservation.observationLocation.full
                    self.stationObservationTime.text = pws.currentObservation.observationTime
                    self.stationTemperature.text = String(pws.currentObservation.temp) + "°F"
                    self.stationDewpoint.text = pws.currentObservation.dewpoint
                    self.stationHumidity.text = pws.currentObservation.relativeHumidity
                    self.stationPressure.text = pws.currentObservation.pressure + " Ins"
                    self.stationWind.text = pws.currentObservation.windDirection
                    self.stationWindSpeed.text = String(pws.currentObservation.windSpeed) + " Mph"
                    self.stationWindGust.text = String(describing: pws.currentObservation.windGust!) + " Mph"
                    self.stationWeather.text = pws.currentObservation.currentWeatherString
                    self.stationPrecip1hr.text = pws.currentObservation.precip1hr + " Ins"
                    self.stationPrecipToday.text = pws.currentObservation.precipToday + " Ins"

                    //self.stationWindDirection.setIcon(icon: .weather(.wi), iconSize: 50, color: .white)
                    
                    self.stationNightDay.text = "Day/Night: " + self.appHelper.nightDay
                    
                    // set the wallpaper based on night or day
                    if self.appHelper.nightDay == "Day" {
                        self.stationWallpaper.image = UIImage(named: "dayImage")
                    }
                    else {
                        self.stationWallpaper.image = UIImage(named: "nightImage")
                    }
                    
                    // show font icon for weather
                    if self.appHelper.nightDay == "Day" {
                        switch pws.currentObservation.icon {
                            case "clear":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/clear.png")
                            case "cloudy":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/cloudy.png")
                            case "flurries":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/flurries.png")
                            case "fog":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/fog.png")
                            case "hazy":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/hazy.png")
                            case "mostlycloudy":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/mostlycloudy.png")
                            case "mostlysunny":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/mostlysunny.png")
                            case "partlycloudy":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/partlycloudy.png")
                            case "partlysunny":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/partlysunny.png")
                            case "sleet":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/sleet.png")
                            case "rain":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/rain.png")
                            case "snow":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/snow.png")
                            case "sunny":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/sunny.png")
                            case "tstorms":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/tstorms.png")
                            default:
                                self.stationWeatherIcon.image = UIImage(named: "Weather/unknown.png")
                        }
                    }
                    else {
                        switch pws.currentObservation.icon {
                            case "clear":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_clear.png")
                            case "cloudy":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_cloudy.png")
                            case "flurries":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_flurries.png")
                            case "fog":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_fog.png")
                            case "hazy":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_hazy.png")
                            case "mostlycloudy":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_mostlycloudy.png")
                            case "mostlysunny":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_mostlysunny.png")
                            case "partlycloudy":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_partlycloudy.png")
                            case "partlysunny":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_partlysunny.png")
                            case "sleet":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_clear.png")
                            case "rain":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_rain.png")
                            case "snow":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_snow.png")
                            case "sunny":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_clear.png")
                            case "tstorms":
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_tstorms.png")
                            default:
                                self.stationWeatherIcon.image = UIImage(named: "Weather/nt_unknown")
                        }
                    }
                }
            } catch DecodingError.keyNotFound(let context) {
                self.appHelper.showAlert(vc: self, titleString: "Missing key", messageString: String(describing: context))
            } catch DecodingError.valueNotFound(let context) {
                self.appHelper.showAlert(vc: self, titleString: "Value not found", messageString: String(describing: context))
            } catch DecodingError.typeMismatch(let context) {
                self.appHelper.showAlert(vc: self, titleString: "Type mismatch", messageString: String(describing: context))
            } catch {
                self.appHelper.showAlert(vc: self, titleString: "Unable to fetch weather", messageString: error.localizedDescription)
            }
        }
        task.resume()
    }
}

