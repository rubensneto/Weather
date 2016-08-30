//
//  CurrentWeather.swift
//  Weather
//
//  Created by Rubens Neto on 13/07/16.
//  Copyright © 2016 Rubens Neto. All rights reserved.
//

import Foundation

struct CurrentWeather {
    
    let temperature: Int?
    let celciusTemperature: Int?
    let precipProbability: Int?
    let summary: String?
    
    init(weatherDictionary: [String: AnyObject]){
        temperature = weatherDictionary["temperature"] as? Int
        celciusTemperature = (temperature! - 32)*5/9
        
        if let precipProbabilityFloat = weatherDictionary["precipProbability"] as? Double{
            precipProbability = Int(precipProbabilityFloat * 100)
        } else {
            precipProbability = nil
        }
        
        summary = weatherDictionary["summary"] as? String
    }
}