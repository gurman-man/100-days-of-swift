//
//  PhotoCell.swift
//  Consolidation5_PhotoList
//
//  Created by mac on 15.05.2025.
//

import UIKit

class PhotoCell: UITableViewCell {
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Оформлення
        backgroundColor = UIColor.systemGroupedBackground
        photoImageView.layer.cornerRadius = 8
        photoImageView.clipsToBounds = true
        captionLabel.textColor = .darkGray
    }
}
