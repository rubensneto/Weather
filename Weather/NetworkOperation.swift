//
//  NetworkOperation.swift
//  Weather
//
//  Created by Rubens Neto on 13/07/16.
//  Copyright © 2016 Rubens Neto. All rights reserved.
//

import Foundation

class NetworkOperation {
    
    lazy var config: URLSessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = URLSession(configuration: self.config)
    let queryURL: URL
    
    typealias JSONDictionaryCompletion = ([String: AnyObject]?) -> Void
    
    init(url: URL){
        self.queryURL = url
    }
    
    func downloadJSONFromURL(_ completion: @escaping JSONDictionaryCompletion) {
        let request: URLRequest = URLRequest(url: queryURL)
        let dataTask = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            // 1: Check HTTP Response for successful GET Resquest 
            
            if let httpResponse = response as? HTTPURLResponse {
                switch(httpResponse.statusCode){
                case 200:
                    
                    // 2: Create JSON object with data
                    
                    do {
                        let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                        completion(jsonDictionary)
                    } catch let error {
                        print("JSON Serialization failed. Error: \(error)")
                    }
                    
                default: print("Unsuccessful HTTP Request! Status Code:\(httpResponse.statusCode)")
                    
                }
                
            } else {
                print("Error: Not valid HTTP Response.")
            }
        })
        
        dataTask.resume()
    }
}
