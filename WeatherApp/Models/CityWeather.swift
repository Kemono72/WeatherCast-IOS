//
//  CityWeather.swift
//  WeatherApp
//
//  Created by Aryan Raj Joshi on 2025-03-20.
//

import Foundation

struct CityWeather: Codable {
    var cityName: String
    var countryCode: String
    var latitude: Double
    var longitude: Double
    var currentTemp: Double?
    var weatherIcon: String?
}
