//
//  PersistenceController.swift
//  WeatherApp
//
//  Created by Aryan Raj Joshi on 2025-03-21.
//

import Foundation

class PersistenceController {
    static let shared = PersistenceController()
    
    private let filename = "cities.plist"
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(filename)
    }
    
    func saveCities(_ cities: [CityWeather]) {
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(cities)
            try data.write(to: fileURL)
        } catch {
            print("Error saving cities: \(error)")
        }
    }
    
    func loadCities() -> [CityWeather] {
        let url = fileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            return [] // Return empty list on first launch
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            let cities = try decoder.decode([CityWeather].self, from: data)
            return cities
        } catch {
            print("Error loading cities: \(error)")
            return []
        }
    }

}
