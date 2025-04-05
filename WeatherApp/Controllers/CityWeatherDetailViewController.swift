//
//  CityWeatherDetailViewController.swift
//  WeatherApp
//
//  Created by Aryan Raj Joshi on 2025-03-23.
//

import UIKit

class CityWeatherDetailViewController: UIViewController, UITableViewDataSource {

    var city: CityWeather?
    var forecast: [ForecastDay] = []

    let currentTempLabel = UILabel()
    let currentDescriptionLabel = UILabel()
    let currentIconImageView = UIImageView()
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        fetchForecast()
    }

    func setupUI() {
        currentTempLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        currentTempLabel.textAlignment = .center

        currentDescriptionLabel.font = UIFont.systemFont(ofSize: 16)
        currentDescriptionLabel.textAlignment = .center

        currentIconImageView.contentMode = .scaleAspectFit
        currentIconImageView.translatesAutoresizingMaskIntoConstraints = false
        currentIconImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        currentIconImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true

        let headerStack = UIStackView(arrangedSubviews: [currentTempLabel, currentIconImageView, currentDescriptionLabel])
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = 6
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.register(ForecastTableViewCell.self, forCellReuseIdentifier: "ForecastCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60


        view.addSubview(headerStack)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func fetchForecast() {
        guard let city = city else { return }

        WeatherController.shared.fetchFiveDayForecast(lat: city.latitude, lon: city.longitude) { forecast, error in
            DispatchQueue.main.async {
                if let forecast = forecast {
                    self.forecast = forecast
                    self.tableView.reloadData()

                    if let today = forecast.first {
                        self.currentTempLabel.text = String(format: "Current: %.1f°C", today.temp - 273.15)
                        self.currentDescriptionLabel.text = "Today’s Forecast"

                        if let url = URL(string: "https://openweathermap.org/img/wn/\(today.icon)@2x.png") {
                            URLSession.shared.dataTask(with: url) { data, _, _ in
                                if let data = data {
                                    DispatchQueue.main.async {
                                        self.currentIconImageView.image = UIImage(data: data)
                                    }
                                }
                            }.resume()
                        }
                    }
                } else {
                    self.currentTempLabel.text = "--"
                    self.currentDescriptionLabel.text = "No forecast available"
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecast.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as? ForecastTableViewCell else {
            return UITableViewCell()
        }

        let day = forecast[indexPath.row]
        cell.dateLabel.text = day.date
        cell.tempLabel.text = String(format: "%.1f°C", day.temp - 273.15)

        if let iconURL = URL(string: "https://openweathermap.org/img/wn/\(day.icon)@2x.png") {
            URLSession.shared.dataTask(with: iconURL) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.iconImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }

        return cell
    }
}
