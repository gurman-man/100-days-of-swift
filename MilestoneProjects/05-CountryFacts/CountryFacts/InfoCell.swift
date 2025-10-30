//
//  InfoCell.swift
//  CountryFacts
//
//  Created by mac on 18.06.2025.
//

import UIKit

class InfoCell: UITableViewCell {
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = .boldSystemFont(ofSize: 15)
        valueLabel.font = .systemFont(ofSize: 15)
        valueLabel.textColor = .darkGray
        
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            
//            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
//        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
