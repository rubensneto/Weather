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
    let forecastBaseURL: URL?
    
    init(APIKey: String){
        self.forecastAPIKey = APIKey
        self.forecastBaseURL = URL(string: "https://api.forecast.io/forecast/\(forecastAPIKey)/")
    }
    
    func getForecast(_ location: CLLocation, completion: @escaping ((CurrentWeather?) -> Void)){
        if let forecastURL = URL(string: "\(location.coordinate.latitude),\(location.coordinate.longitude)", relativeTo: forecastBaseURL){
            
            let networkOperation = NetworkOperation(url: forecastURL)
            networkOperation.downloadJSONFromURL{
                (JSONDictionary) in
                let currentWeather = self.currentWeatherFromJSON(JSONDictionary)
                completion(currentWeather)
            }
            
        } else {
            print("Could not construct a valid URL")
        }
    }
    
    func currentWeatherFromJSON(_ jsonDictionary: [String: AnyObject]?) ->CurrentWeather? {
        if let currentWeatherDictionary = jsonDictionary?["currently"] as? [String: AnyObject]{
            return CurrentWeather(weatherDictionary: currentWeatherDictionary)
        } else {
            print("JSON dictionary returned nil for 'currently' key")
            return nil
        }
    }
}
