//
//  WeatherDataModel.swift
//  RenfroWeather
//
//  Created by Roger Renfro on 3/8/18.
//  Copyright © 2018 Roger Renfro. All rights reserved.
//

import UIKit

class WeatherDataModel {

    // MARK: Astronomy structure
    // **********************************************************************************
    //
    // **********************************************************************************
    
    public struct AstronomyJSONStruct: Codable {
        public var sun_phase: sunphaseStruct
        public var moon_phase: moonphaseStruct
    }

    public struct sunphaseStruct: Codable {
        public var sunrise: sunriseStruct
        public var sunset: sunsetStruct
    }

    public struct sunriseStruct: Codable {
        public var hour: String
        public var minute: String
    }

    public struct sunsetStruct: Codable {
        public var hour: String
        public var minute: String
    }

    public struct moonphaseStruct: Codable {
        public var ageOfMoon: String
        public var hemisphere: String
        public var moonrise: moonriseStruct
        public var moonset: moonsetStruct
        public var percentIlluminated: String
        public var phaseofMoon: String
    }

    public struct moonriseStruct: Codable {
        public var hour: String!
        public var minute: String!
    }

    public struct moonsetStruct: Codable {
        public var hour: String
        public var minute: String
    }
    
    public struct WeatherJSONStruct: Codable {
        
        // Use the currentObservation, it is the top key to the entire JSON tree of data
        public var currentObservation:currentObservationStruct
        
        enum CodingKeys: String, CodingKey {
            case currentObservation = "current_observation"
        }
    }
    
    // MARK: Weather structure
    // **********************************************************************************
    //
    // **********************************************************************************

    public struct currentObservationStruct: Codable {
        //public var displayLocation: displayLocationStruct
        public var observationLocation: observationLocationStruct
        public var observationTime: String
        public var precipToday: String
        public var precip1hr: String
        public var currentWeatherString: String
        public var pressure: String
        public var temp: Double
        public var dewpoint: String
        public var relativeHumidity: String
        public var windDirection: String
        public var windSpeed: Double
        public var windGust: String?
        public var icon: String
        public var iconURL: URL
        
        enum CodingKeys: String, CodingKey {
            //case displayLocation = "display_location"
            case observationLocation = "observation_location"
            case observationTime = "observation_time"
            case currentWeatherString = "weather"
            case precipToday = "precip_today_in"
            case precip1hr = "precip_1hr_in"
            case pressure = "pressure_in"
            case temp = "temp_f"
            case dewpoint = "dewpoint_string"
            case relativeHumidity = "relative_humidity"
            case windDirection = "wind_dir"
            case windSpeed = "wind_mph"
            case windGust = "wind_gust_mph"
            case icon = "icon"
            case iconURL = "icon_url"
        }
        public init (from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy:CodingKeys.self)
            //let displayValues = try values.nestedContainer(keyedBy: displayLocationStruct.DisplayKeys.self, forKey: .displayLocation)
            //displayLocation = try values.decode(displayLocationStruct.self, forKey: .displayLocation)
            //displayLocation.cityState = try displayValues.decode(String.self, forKey: displayLocationStruct.DisplayKeys(rawValue: displayLocation.cityState)!)
            
            let observationValues = try values.nestedContainer(keyedBy: observationLocationStruct.ObservationKeys.self, forKey: .observationLocation)
            observationLocation = try values.decode(observationLocationStruct.self, forKey: .observationLocation)
            observationLocation.full = try observationValues.decode(String.self, forKey: .full)
            observationTime = try values.decode(String.self, forKey: .observationTime)
            currentWeatherString =  try values.decode(String.self, forKey: .currentWeatherString)
            precipToday = try values.decode(String.self, forKey: .precipToday)
            precip1hr = try values.decode(String.self, forKey: .precip1hr)
            pressure = try values.decode(String.self, forKey: .pressure)
            temp = try values.decode(Double.self, forKey: .temp)
            dewpoint = try values.decode(String.self, forKey: .dewpoint)
            relativeHumidity = try values.decode(String.self, forKey: .relativeHumidity)
            windDirection = try values.decode(String.self, forKey: .windDirection)
            windSpeed = try values.decode(Double.self, forKey: .windSpeed)
            do {
                // if wind gust is zero it's a double
                windGust = String((try values.decode(Double.self, forKey: .windGust)))
            } catch {
                // if wind gust is non-zero it's a string
                windGust = (try values.decode(String.self, forKey: .windGust))
            }
            //windGust = (try values.decodeIfPresent(Double.self, forKey: .windGust)) ?? 0.0
            icon = try values.decode(String.self, forKey: .icon)
            iconURL = try values.decode(URL.self, forKey: .iconURL)
        }
    }
    
    public struct observationLocationStruct: Codable {
        public var full: String
        public var city: String
        public var state: String
        public var elevation: String
        
        enum ObservationKeys: String, CodingKey {
            case full = "full"
            case city = "city"
            case state = "state"
            case elevation = "elevation"
        }
    }
    
    //public struct displayLocationStruct: Codable {
    //    public var cityState: String
    //    public var city: String
    //    public var state: String
    //    public var zip: String
    //    public var latitude: String
    //    public var longitude: String
    //
    //    enum DisplayKeys: String, CodingKey {
    //        case cityState = "full"
    //        case city = "city"
    //        case state = "state"
    //        case zip = "zip"
    //        case latitude = "latitude"
    //        case longitude = "longitude"
    //    }
    //}
    
}
