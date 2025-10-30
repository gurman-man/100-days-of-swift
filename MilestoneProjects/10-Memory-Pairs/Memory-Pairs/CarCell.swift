//
//  CarCell.swift
//  Memory-Pairs
//
//  Created by mac on 28.08.2025.

/// Клас клітинки відповідає за відображення картки.
/// configure(with:isFaceUP:) вирішує, що показувати: фронт картки чи її тильну сторону.
/// Є масштабування логотипів і правильне відображення фото.
/// Можна легко додати кастомний фон через cardBackView.


import UIKit

class CarCell: UICollectionViewCell {
    @IBOutlet weak var carImageView: UIImageView!       // Зображення машини або логотипу
    @IBOutlet weak var cardBackView: UIView!            // для фону, коли карта закрита
    @IBOutlet weak var label: UILabel!                  // Підпис на картці ("Brand" або "Car")
    
    var array: [String]?
    
    // Вирішує, що показувати: фронт картки чи її тильну сторону.
    func configure(with card: CarCard, isFaceUP: Bool) {
        if isFaceUP {
            // Картка відкрита: показуємо фото або логотип
            carImageView.image = UIImage(named: card.imageName)
            cardBackView.isHidden = true
            label.isHidden = true
            
            // Логотипи зменшені, щоб виглядали акуратно
            if card.isBrand {
                carImageView.contentMode = .scaleAspectFit
                carImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            } else {
                // Фото машини займає всю клітинку
                carImageView.contentMode = .scaleAspectFill
                carImageView.transform = .identity // початковий розмір
            }
        } else {
            // Картка закрита: показуємо фон
            carImageView.image = nil
            cardBackView.isHidden = false
            
            label.isHidden = false
            label.text = card.type == .logo ? "Brand" : "Car"
            
            // ← Сюди вставляєш код для картинки-фону
            cardBackView.layer.contents = UIImage(named: "background")?.cgImage
            cardBackView.layer.contentsGravity = .resize
            carImageView.transform = .identity  // початковий розмір
        }
    }
}
