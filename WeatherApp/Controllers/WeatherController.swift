//
//  WeatherController.swift
//  WeatherApp
//
//  Created by Aryan Raj Joshi on 2025-03-20.
//

import Foundation

class WeatherController {
    static let shared = WeatherController()

    private let session = URLSession.shared
    private let apiKey = "19a0c5e0e8msha41955be153cf96p1382c5jsne1ed7ede941a"
    private let apiHost = "open-weather13.p.rapidapi.com"

    func fetchCurrentWeather(city: String, regionCode: String, completion: @escaping (Double?, String?, Double?, Double?, Error?) -> Void) {
        let path = "\(city)/\(regionCode)"
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        guard let url = URL(string: "https://open-weather13.p.rapidapi.com/city/\(encodedPath)") else {
            completion(nil, nil, nil, nil, NSError(domain: "BadURL", code: -1))
            return
        }

        print("[Requesting Current Weather] URL: \(url)")

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue(apiHost, forHTTPHeaderField: "X-RapidAPI-Host")

        session.dataTask(with: request) { data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            print("[HTTP Status] \(statusCode)")
            print("[Current Weather Raw JSON]:\n\(String(data: data ?? Data(), encoding: .utf8) ?? "nil")")

            guard let data = data, error == nil else {
                completion(nil, nil, nil, nil, error)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let main = json["main"] as? [String: Any],
                   let temp = main["temp"] as? Double,
                   let weather = json["weather"] as? [[String: Any]],
                   let icon = weather.first?["icon"] as? String,
                   let coord = json["coord"] as? [String: Any],
                   let lat = coord["lat"] as? Double,
                   let lon = coord["lon"] as? Double {
                    completion(temp, icon, lat, lon, nil)
                } else {
                    print("[Parse Error] Missing expected fields in response.")
                    completion(nil, nil, nil, nil, NSError(domain: "ParseError", code: -2))
                }
            } catch {
                completion(nil, nil, nil, nil, error)
            }
        }.resume()
    }


    func fetchFiveDayForecast(lat: Double, lon: Double, completion: @escaping ([ForecastDay]?, Error?) -> Void) {
        let urlString = "https://open-weather13.p.rapidapi.com/city/fivedaysforcast/\(lat)/\(lon)"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "BadURL", code: -1))
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue(apiHost, forHTTPHeaderField: "X-RapidAPI-Host")

        session.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Forecast fetch failed: \(error)")
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, NSError(domain: "NoData", code: -3))
                return
            }

            // Debug
            print("📥 [DEBUG] Forecast Raw:\n\(String(data: data, encoding: .utf8) ?? "")")

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                var forecastDays: [ForecastDay] = []

                if let list = json?["list"] as? [[String: Any]] {
                    let inputFormatter = DateFormatter()
                    inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "EEE, MMM d"

                    var addedDates = Set<String>()

                    for entry in list {
                        if let dt_txt = entry["dt_txt"] as? String,
                           let date = inputFormatter.date(from: dt_txt),
                           let main = entry["main"] as? [String: Any],
                           let temp = main["temp"] as? Double,
                           let weatherArray = entry["weather"] as? [[String: Any]],
                           let icon = weatherArray.first?["icon"] as? String {

                            let displayDate = outputFormatter.string(from: date)
                            if !addedDates.contains(displayDate) {
                                forecastDays.append(ForecastDay(date: displayDate, temp: temp, icon: icon))
                                addedDates.insert(displayDate)
                            }
                        }

                        if forecastDays.count >= 5 { break }
                    }
                }

                completion(forecastDays, nil)
            } catch {
                print("Forecast JSON decode failed: \(error)")
                completion(nil, error)
            }
        }.resume()
    }
}
