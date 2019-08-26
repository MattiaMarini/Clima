//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Mattia Marini on 18/07/2019.
//  Copyright © 2019 Mattia Marini. All rights reserved.
//

import UIKit


//Writing protocol to change the city for forecast:

protocol ChangeCityDelegate {
    func userChangedCityName(city : String)
}

class ChangeCityViewController: UIViewController {
    
    //Protocol needs a delegate
    var delegate : ChangeCityDelegate?
    
    //Declaring text field Outlet and 'Get Weather 'Action button:
    @IBOutlet weak var changeCityTextField: UITextField!
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        
        //Catch city name entered in text field, pass it into a function, then dismiss segue and go back to main view
        let cityName = changeCityTextField.text!
        delegate?.userChangedCityName(city: cityName)
        self.dismiss(animated: true, completion: nil)
    }
    
    //Dismiss ChangeCityViewController by pressing 'Back'.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
