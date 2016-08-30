//
//  ForecastService.swift
//  Weather
//
//  Created by Rubens Neto on 13/07/16.
//  Copyright © 2016 Rubens Neto. All rights reserved.
//

import Foundation
import CoreLocation

struct ForecastService {
    
    let forecastAPIKey: String
    let forecastBaseURL: NSURL?
    
    init(APIKey: String){
        self.forecastAPIKey = APIKey
        self.forecastBaseURL = NSURL(string: "https://api.forecast.io/forecast/\(forecastAPIKey)/")
    }
    
    func getForecast(location: CLLocation, completion: (CurrentWeather? -> Void)){
        if let forecastURL = NSURL(string: "\(location.coordinate.latitude),\(location.coordinate.longitude)", relativeToURL: forecastBaseURL){
            
            let networkOperation = NetworkOperation(url: forecastURL)
            networkOperation.downloadJSONFromURL{
                (let JSONDictionary) in
                let currentWeather = self.currentWeatherFromJSON(JSONDictionary)
                completion(currentWeather)
            }
            
        } else {
            print("Could not construct a valid URL")
        }
    }
    
    func currentWeatherFromJSON(jsonDictionary: [String: AnyObject]?) ->CurrentWeather? {
        if let currentWeatherDictionary = jsonDictionary?["currently"] as? [String: AnyObject]{
            return CurrentWeather(weatherDictionary: currentWeatherDictionary)
        } else {
            print("JSON dictionary returned nil for 'currently' key")
            return nil
        }
    }
}
