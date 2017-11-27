//
//  ViewController.swift
//  Clima
//
//  Created by Stu Combs on 10/24/17.
//  Copyright © 2017 Stu Combs. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    let weatherUrl = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "786fef66b9895a3a73cf7d0236541a97"
    
    let manager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
    }
    
    //MARK: Networking
    
    func getWeatherData(url: String, parameters: [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                let weatherJSON: JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            } else {
                print("Error: \(response.result.error)")
                self.cityLabel.text = "Connection Issue"
                self.cityLabel.sizeToFit()
            }
        }
    }
    
    //MARK: JSON Parsing
    func updateWeatherData(json: JSON) {
        if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = Int((tempResult*(9/5)) - 459.67)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIcon = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIData()
            
        } else {
            cityLabel.text = "Weather not available"
        }
    }
    
    //MARK: UI Updates
    func updateUIData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        temperatureLabel.adjustsFontSizeToFitWidth = true
        weatherImage.image = UIImage(named: weatherDataModel.weatherIcon!)
        
    }
    
    //MARK: Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            manager.stopUpdatingLocation()
        }
        
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        print("Latitude = \(latitude), Longitude = \(longitude)")
        
        let params: [String : String] = ["lat" : latitude, "lon" : longitude, "appID" : APP_ID]
        getWeatherData(url: weatherUrl, parameters: params)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "Location Unavailable"
    }
    
    func userEnteredACityName(city: String) {
        let params: [String : String] = ["q": city, "appid": APP_ID]
        
        getWeatherData(url: weatherUrl, parameters: params)
    }
    
    //MARK: Change City Del
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "switchSegue" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }

}

