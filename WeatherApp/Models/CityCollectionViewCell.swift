//
//  CityCollectionViewCell.swift
//  WeatherApp
//
//  Created by Aryan Raj Joshi on 2025-03-23.
//

import UIKit

class CityCollectionViewCell: UICollectionViewCell {
    let cityLabel = UILabel()
    let tempLabel = UILabel()
    let weatherIcon = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCellUI()
    }

    private func setupCellUI() {
        contentView.backgroundColor = UIColor.systemGray6
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        weatherIcon.contentMode = .scaleAspectFit
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        weatherIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        weatherIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true

        cityLabel.font = UIFont.boldSystemFont(ofSize: 18)
        cityLabel.textColor = .label
        cityLabel.translatesAutoresizingMaskIntoConstraints = false

        tempLabel.font = UIFont.systemFont(ofSize: 16)
        tempLabel.textColor = .secondaryLabel
        tempLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [weatherIcon, cityLabel])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        contentView.addSubview(tempLabel)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            tempLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 4),
            tempLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            tempLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            tempLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
