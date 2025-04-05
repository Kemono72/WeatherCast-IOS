//
//  SearchCityViewController.swift
//  WeatherApp
//
//  Created by Aryan Raj Joshi on 2025-03-22.
//

import UIKit

class SearchCityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    let cityTextField = UITextField()
    let addButton = UIButton(type: .system)
    let suggestionsTableView = UITableView()
    var suggestions: [String] = []

    var onCityAdded: ((CityWeather) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Add City"
        setupLayout()
    }

    func setupLayout() {
        cityTextField.placeholder = "Start typing city name..."
        cityTextField.borderStyle = .roundedRect
        cityTextField.delegate = self
        cityTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        addButton.setTitle("Add City", for: .normal)
        addButton.addTarget(self, action: #selector(addCityTapped), for: .touchUpInside)

        suggestionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
        suggestionsTableView.dataSource = self
        suggestionsTableView.delegate = self

        [cityTextField, addButton, suggestionsTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            cityTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cityTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cityTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            addButton.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 12),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            suggestionsTableView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 12),
            suggestionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc func textFieldDidChange() {
        guard let query = cityTextField.text?.trimmingCharacters(in: .whitespaces), !query.isEmpty else {
            suggestions = []
            suggestionsTableView.reloadData()
            return
        }

        let urlStr = "http://gd.geobytes.com/AutoCompleteCity?q=\(query)"
        guard let url = URL(string: urlStr) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let rawSuggestions = try? JSONDecoder().decode([String].self, from: data) else { return }

            let filtered = rawSuggestions.filter {
                $0.split(separator: ",").count == 3
            }

            DispatchQueue.main.async {
                self.suggestions = filtered
                self.suggestionsTableView.reloadData()
            }
        }.resume()
    }

    @objc func addCityTapped() {
        guard let selected = cityTextField.text,
              suggestions.contains(selected),
              let (city, region) = parseCityAndRegion(from: selected) else {
            showAlert(title: "Invalid", message: "Please select a valid city from suggestions.")
            return
        }

        print("🌆 Selected: \(city), \(region)")

        WeatherController.shared.fetchCurrentWeather(city: city, regionCode: region) { temp, icon, lat, lon, error in
            DispatchQueue.main.async {
                guard let lat = lat, let lon = lon else {
                    self.showAlert(title: "City Not Found", message: "\(city), \(region) may not exist in API. Try another city.")
                    return
                }

                let cityObj = CityWeather(
                    cityName: city,
                    countryCode: region,
                    latitude: lat,
                    longitude: lon,
                    currentTemp: temp ?? 0.0, // fallback to 0
                    weatherIcon: icon ?? "01d"
                )


                self.onCityAdded?(cityObj)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }


    func parseCityAndRegion(from string: String) -> (String, String)? {
        let parts = string.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if parts.count == 3 {
            let city = parts[0]
            let countryName = parts[2]

            let locale = Locale(identifier: "en_US")
            for region in Locale.Region.isoRegions {
                if let name = locale.localizedString(forRegionCode: region.identifier),
                   name.lowercased() == countryName.lowercased() {
                    return (city, region.identifier) 
                }
            }
        }
        return nil
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
        cell.textLabel?.text = suggestions[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cityTextField.text = suggestions[indexPath.row]
        cityTextField.resignFirstResponder()
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
