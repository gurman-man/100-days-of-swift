//
//  CarCard.swift
//  Memory-Pairs
//
//  Created by mac on 27.08.2025.

/// Модель CarCard зберігає дані про картку.
/// pairId дозволяє перевіряти пари.
/// type і isBrand допомагають налаштовувати UI (логотип чи фото).

import UIKit

enum CardType {
    case logo, photo        // Тип картки: логотип або фото
}


struct CarCard {
    let id: UUID            // Унікальний ідентифікатор картки
    let pairId: String      // спільний ідентифікатор, щоб можна було перевіряти відповідність.
    let imageName: String   // назва картинки в Assets
    var isMatched: Bool     // Стан карти (відкрита/знайдена)
    
    let type: CardType      // Тип картки
    
    // Допоміжне поле: логотипи мають "_logo" у назві
    var isBrand: Bool {
        imageName.contains("_logo")
    }
}
