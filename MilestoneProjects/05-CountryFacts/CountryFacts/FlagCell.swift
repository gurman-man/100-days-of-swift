//
//  FlagCell.swift
//  CountryFacts
//
//  Created by mac on 17.06.2025.
//

import UIKit

class FlagCell: UITableViewCell {
    let flagImageView = UIImageView()
    let countryLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        flagImageView.contentMode = .scaleAspectFit
        flagImageView.layer.cornerRadius = 6
        flagImageView.clipsToBounds = true
        flagImageView.layer.borderWidth = 0.5
        flagImageView.layer.borderColor = UIColor.systemGray.cgColor
        
        countryLabel.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        
        contentView.addSubview(flagImageView)
        contentView.addSubview(countryLabel)
        
        flagImageView.translatesAutoresizingMaskIntoConstraints = false
        countryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            flagImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            flagImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            flagImageView.widthAnchor.constraint(equalToConstant: 50),
            flagImageView.heightAnchor.constraint(equalToConstant: 30),
            
            countryLabel.leadingAnchor.constraint(equalTo: flagImageView.trailingAnchor, constant: 16),
            countryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            countryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
