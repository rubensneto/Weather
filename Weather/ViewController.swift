//
//  ViewController.swift
//  Weather
//
//  Created by Rubens Neto on 12/07/16.
//  Copyright © 2016 Rubens Neto. All rights reserved.
//
// Tap and hold in a place to check out its weather

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    let currentCoordinades = CLGeocoder()
    
    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var currentCitySummary: UILabel!
    @IBOutlet weak var currentCityTemperature: UILabel!
    @IBOutlet weak var currentCityRainProb: UILabel!
    @IBOutlet weak var backgroundLabel: UILabel!
    
    @IBOutlet var screenView: UIView!
    
    let forecastService = ForecastService(APIKey: "6d6dfc92fdcbbbebc06fed124e1509e3")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        backgroundLabel.layer.cornerRadius = 5
        backgroundLabel.layer.masksToBounds = true
        
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
        longPressGesture()
    }
    
    func longPressGesture(){
        let lpg = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressAction))
        lpg.minimumPressDuration = 2
        mapView.addGestureRecognizer(lpg)
    }
    
    func longPressAction(longPress: UILongPressGestureRecognizer){
        let touchedPoint = longPress.locationInView(mapView)
        let touchedCoordinates = mapView.convertPoint(touchedPoint, toCoordinateFromView: mapView)
        let center = CLLocationCoordinate2D(latitude: touchedCoordinates.latitude, longitude: touchedCoordinates.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
        currentLocation = CLLocation(latitude: touchedCoordinates.latitude, longitude: touchedCoordinates.longitude)
        getCityName(currentLocation)
        getWeatherForCurrentLocation(currentLocation)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
        let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
        getCityName(currentLocation)
        getWeatherForCurrentLocation(currentLocation)
    }
    
    func getCityName(location: CLLocation){
        CLGeocoder().reverseGeocodeLocation(location) { (myLocations, error) in
            if error != nil {
                self.currentCity.text = "Not able to access the server."
                self.currentCitySummary.text = "Please try again later."
            } else {
                if let location = myLocations?.first {
                    if location.locality != nil {
                        self.currentCity.text = "\(location.locality!), \(location.country!)"
                    } else if location.ocean != nil {
                        self.currentCity.text = "\(location.ocean!)"
                    } else if location.country != nil{
                        self.currentCity.text = "\(location.country!)"
                    } else {
                        self.currentCity.text = "\(location.location!.coordinate.latitude), \(location.location!.coordinate.longitude)"
                    }
                }
            }
        }
    }

    @IBAction func findMyLocation(sender: UIButton) {
        viewDidLoad()
    }
    
    func getWeatherForCurrentLocation(location: CLLocation){
        forecastService.getForecast(location) {(let currently) in
            if let currentWeather = currently {
                dispatch_async(dispatch_get_main_queue()) {
                    if let temperature = currentWeather.celciusTemperature {
                        self.currentCityTemperature?.text = "\(temperature)"
                        self.changeBackgroundColor(self.screenView, temperature: temperature)
                        
                    }
                    
                    if let summary = currentWeather.summary {
                        self.currentCitySummary?.text = "\(summary)"
                    }
                    
                    if let precipProb = currentWeather.precipProbability {
                        self.currentCityRainProb.text = "Probability of rain: \(precipProb)%"
                    } else {
                        self.currentCityRainProb.text = "Probability of rain not available"
                    }
                }
            } else {
                self.currentCity.text = "Not able to access the server."
                self.currentCitySummary.text = "Please try again later."
            }
        }
    }
    
    func changeBackgroundColor(view: UIView, temperature: Int) {
        switch temperature {
        case 12..<25:
            view.backgroundColor = UIColor(red: 127/255.0, green: 178/255.0, blue: 240/255.0, alpha: 1.0)
            //label.backgroundColor = UIColor(red: 127/255.0, green: 178/255.0, blue: 240/255.0, alpha: 0.85)
        case 25..<100:
            view.backgroundColor = UIColor(red: 255/255.0, green: 194/255.0, blue: 88/255.0, alpha: 1.0)
            //label.backgroundColor = UIColor(red: 78/255.0, green: 122/255.0, blue: 199/255.0, alpha: 0.85)
        default:
            view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let isFirstOpen = NSUserDefaults.standardUserDefaults().stringForKey("isFirstOpen")
        
        if isFirstOpen != "no" {
            let alertMessage = "Tap and hold in a place to check out its weather."
            let alertTitle = "Welcome!"
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            NSUserDefaults.standardUserDefaults().setObject("no", forKey: "isFirstOpen")
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}

