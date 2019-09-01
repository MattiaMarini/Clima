//
//  ViewController.swift
//  WeatherApp
//
//  Created by Mattia Marini on 18/07/2019.
//  Copyright © 2019 Mattia Marini. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "d0d5c4cf12f4ef0bf41d2749c9eb2eb5"
    
    //Declare instance variables
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Location manager config
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Getting Weather Data method:
   
    func getWeatherData2(parameters : [String : String]!) {
        
        let finalUrl = "\(WEATHER_URL)?lat=\(parameters["lat"]!.description)&lon=\(parameters["lon"]!.description)&APPID=\(parameters["appid"]!.description)"
        let request = URLRequest(url: URL(string: finalUrl)!)
        let session = URLSession.shared
        _ = session.dataTask(with: request) { (data, response, error) in
            
            if let dataReceived = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: dataReceived, options:.allowFragments) as? [String: AnyObject] {
                        
                        self.updateWeatherData(json)
                      
                    }
                    
                } catch {
                    
                    print("error serializing JSON: \(error)")
                    
                }
            }
        } .resume()
        
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Updating Weather Data method:
    
    func updateWeatherData(_ json: [String : AnyObject]) {
        
        if let temperature = json["main"]?["temp"] as? Double {
            self.weatherDataModel.temperature = Int(temperature - 273.15)
            self.weatherDataModel.city = json["name"] as! String
            let weather : Array<Dictionary<String, AnyObject>> = json["weather"] as! Array
            self.weatherDataModel.condition = weather[0]["id"] as! Int
            self.weatherDataModel.weatherIconName = self.weatherDataModel.updateWeatherIcon(condition: self.weatherDataModel.condition)
            
            self.updateUIWithWeatherData()
        }
        
    }

    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Updating UI method:
    func updateUIWithWeatherData() {
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        cityLabel.text = weatherDataModel.city
    }
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Getting location from Location Manager method :
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        //Sets the CLLM to stop working as soon as it has a valid reading (negative coords are wrong)
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("Longitude = \(location.coordinate.longitude), Latitude = \(location.coordinate.latitude)")
            
            //creating variables from GPS data collected from phone
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            //getWeatherData(url : WEATHER_URL, parameters : params)
            getWeatherData2(parameters: params)
            
        }
    }
    
    
    //Unable to get location method:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //User entered a new city method :
    func userChangedCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData2(parameters: params)
        
    }

    
    //PrepareForSegue Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
            
        }
    }
    var isOn : Bool = false
    @IBAction func switchPressed(_ sender: Any) {
        if isOn == false {
        temperatureLabel.text = "\(weatherDataModel.temperature * (9/5) + 32)°"
            isOn = true
        }
        else {
            temperatureLabel.text = "\(weatherDataModel.temperature)°"
            isOn = false
        }
    }
}


