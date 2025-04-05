//
//  CityCollectionViewController.swift
//  WeatherApp
//
//  Created by Aryan Raj Joshi on 2025-03-23.
//
import UIKit

class CityCollectionViewController: UICollectionViewController {

    var cities: [CityWeather] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCities()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let padding: CGFloat = 16
            let itemWidth = (view.bounds.width - padding * 3) / 2 // 2 columns
            layout.itemSize = CGSize(width: itemWidth, height: 100)
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        }

        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshWeatherData()
    }

    private func setupNavigationBar() {
        title = "Weather Watchlist"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addCityTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete All", style: .plain,
                                                           target: self,
                                                           action: #selector(deleteAllCities))
    }

    @objc func addCityTapped() {
        let searchVC = SearchCityViewController()
        searchVC.onCityAdded = { [weak self] newCity in
            self?.cities.append(newCity)
            PersistenceController.shared.saveCities(self?.cities ?? [])
            self?.collectionView.reloadData()
        }
        navigationController?.pushViewController(searchVC, animated: true)
    }

    @objc func deleteAllCities() {
        cities.removeAll()
        PersistenceController.shared.saveCities(cities)
        collectionView.reloadData()
    }

    func loadCities() {
        cities = PersistenceController.shared.loadCities()
    }

    func refreshWeatherData() {
        for (index, city) in cities.enumerated() {
            WeatherController.shared.fetchFiveDayForecast(lat: city.latitude, lon: city.longitude) { forecast, error in
                DispatchQueue.main.async {
                    if let forecast = forecast, let firstDay = forecast.first {
                        self.cities[index].currentTemp = firstDay.temp
                        self.cities[index].weatherIcon = firstDay.icon
                        PersistenceController.shared.saveCities(self.cities)
                        self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                }
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cities.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityCell", for: indexPath) as? CityCollectionViewCell else {
            return UICollectionViewCell()
        }

        let city = cities[indexPath.item]
        cell.cityLabel.text = city.cityName
        if let temp = city.currentTemp {
            cell.tempLabel.text = String(format: "%.1f°C", temp - 273.15)
        } else {
            cell.tempLabel.text = "--"
        }

        if let icon = city.weatherIcon,
           let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        if let currentCell = collectionView.cellForItem(at: indexPath) as? CityCollectionViewCell {
                            currentCell.weatherIcon.image = UIImage(data: data)
                        }
                    }
                }
            }.resume()
        } else {
            cell.weatherIcon.image = nil
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = CityWeatherDetailViewController()
        detailVC.city = cities[indexPath.item]
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
