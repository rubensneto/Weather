//
//  NetworkOperation.swift
//  Weather
//
//  Created by Rubens Neto on 13/07/16.
//  Copyright © 2016 Rubens Neto. All rights reserved.
//

import Foundation

class NetworkOperation {
    
    lazy var config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var session: NSURLSession = NSURLSession(configuration: self.config)
    let queryURL: NSURL
    
    typealias JSONDictionaryCompletion = ([String: AnyObject]?) -> Void
    
    init(url: NSURL){
        self.queryURL = url
    }
    
    func downloadJSONFromURL(completion: JSONDictionaryCompletion) {
        let request: NSURLRequest = NSURLRequest(URL: queryURL)
        let dataTask = session.dataTaskWithRequest(request){
            (let data, let response, let error) in
            
            // 1: Check HTTP Response for successful GET Resquest 
            
            if let httpResponse = response as? NSHTTPURLResponse {
                switch(httpResponse.statusCode){
                case 200:
                    
                    // 2: Create JSON object with data
                    
                    do {
                        let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]
                        completion(jsonDictionary)
                    } catch let error {
                        print("JSON Serialization failed. Error: \(error)")
                    }
                    
                default: print("Unsuccessful HTTP Request! Status Code:\(httpResponse.statusCode)")
                    
                }
                
            } else {
                print("Error: Not valid HTTP Response.")
            }
        }
        
        dataTask.resume()
    }
}
