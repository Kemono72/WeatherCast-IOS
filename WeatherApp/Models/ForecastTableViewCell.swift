//
//  ForecastTableViewCell.swift
//  WeatherApp
//
//  Created by Aryan Raj Joshi on 2025-03-23.
//

// ForecastTableViewCell.swift

import UIKit

class ForecastTableViewCell: UITableViewCell {

    let dateLabel = UILabel()
    let tempLabel = UILabel()
    let iconImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tempLabel.font = UIFont.systemFont(ofSize: 16)
        iconImageView.contentMode = .scaleAspectFit

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(iconImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(tempLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),

            dateLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            tempLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            tempLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tempLabel.leadingAnchor.constraint(greaterThanOrEqualTo: dateLabel.trailingAnchor, constant: 8)
        ])
    }
}

