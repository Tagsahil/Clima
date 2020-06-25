//
//  ViewController.swift
//  Clima
//
//  Created by Sahil Tagunde on 12/06/20.
//  Copyright © 2020 sahiltagunde. All rights reserved.

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire

class ViewController: UIViewController,CLLocationManagerDelegate,UITextFieldDelegate  {

    //Constants
    let WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e4ca4824a56de9b8d70bddeb455bfe03"
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    @IBOutlet weak var upperview: UIView!
    @IBOutlet weak var searchCity: UITextField!
    @IBOutlet weak var temLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
        
        textFieldborder()
    }

    
    
    func textFieldborder() {
        
searchCity.delegate = self
        upperview.layer.borderWidth = 1
        upperview.layer.cornerRadius = 15
        //upperview.layer.borderColor = UIColor.black.cgColor
        
    }
    
        //MARK: - Networking
        /***************************************************************/
        
        //Write the getWeatherData method here:
        
        func getWeatherData(url:String, parameter:[String:String]){
            AF.request(url,method: .get,parameters: parameter).responseJSON{
                response in
                 
                switch response.result {
                case let .success(value):
                    print(value)
                    let weatherJSON:JSON = JSON(value)
                    self.updateWeatherData(json: weatherJSON)
                case let .failure(error):
                    print(error)
                    self.weatherImage.image = UIImage(named: "Cloud-Refresh")
                    self.cityLabel.text = "Network Unavailable."
                }
        
            }

        }
        
        //MARK: - JSON Parsing
        /***************************************************************/
       
        
        //Write the updateWeatherData method here:
        
        func updateWeatherData(json:JSON){
            
            if let tempResult = json["main"]["temp"].double{
            weatherDataModel.temperture = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
                updateUIWithWeatherData()
            }
            else{
                
                
                
                if searchCity.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                    
                    let alert = UIAlertController(title: "Alert", message: "Please Enter Valid City Name.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                                    
                  
                    
                }
                
                let alert = UIAlertController(title: "Alert", message: "Please Enter Valid City Name.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                                temLabel.text = .none
                                  weatherImage.image = UIImage(named: "dunno")
                                  cityLabel.text = "Weather Unavailable"
               
            }
            
        }
        
        
        
        //MARK: - UI Updates
        /***************************************************************/
        
        
        //Write the updateUIWithWeatherData method here:
        
       func updateUIWithWeatherData(){
        
        cityLabel.text = weatherDataModel.city
        temLabel.text = "\(weatherDataModel.temperture)°"
        weatherImage.image = UIImage(named: weatherDataModel.weatherIconName)
        }
        
        
        
        
        //MARK: - Location Manager Delegate Methods
        /***************************************************************/
        
        
        //Write the didUpdateLocations method here:
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location = locations[locations.count - 1]
            if location.horizontalAccuracy > 0{
                locationManager.stopUpdatingLocation()
                print("Longitude: \(location.coordinate.longitude),Latitude: \(location.coordinate.latitude)")
                let latitude = String(location.coordinate.latitude)
                let longitude = String(location.coordinate.longitude)
                let params : [String:String] = ["lat":latitude,"lon":longitude,"appid":APP_ID]
                
                getWeatherData(url:WEATHER_URL,parameter:params)
            }
        }
        
        //Write the didFailWithError method here:
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error)
            
            weatherImage.image = UIImage(named: "Cloud-Refresh")
            cityLabel.text = "Netwok Unavialable."
        }
        
        
        func cityChange(){
            
            let cityN = searchCity.text!
            let parameterss : [String:String] = ["q":cityN,"appid":APP_ID]
                
            getWeatherData(url: WEATHER_URL, parameter: parameterss)
            
        }
        
        //MARK:Current Location Buuton
        /*Current Location*/
        
        @IBAction func currentLocation(_ sender: Any) {
            
           
            locationManager.startUpdatingLocation()
            self.searchCity.text = nil
         
            self.view.endEditing(true)
            
            
        }
        
        //MARK:Function for return
        /*Funtion for return*/
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            cityChange()
            return true
        }
           
        
    }
    

  


