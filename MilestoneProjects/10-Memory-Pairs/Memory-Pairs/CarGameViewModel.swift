//
//  CarGameViewModel.swift
//  Memory-Pairs
//
//  Created by mac on 30.08.2025.
//

/// ViewModel відповідає за логіку гри, окремо від UI.
/// Вона зберігає картки, перевіряє пари і перемогу, веде лічильник ходів.
/// Кожна картка має pairId, щоб логотип і фото правильно співпадали.

import UIKit

class CarGameViewModel {
    // Масив всіх карток гри
    private(set) var carCards: [CarCard] = []
    
    // Індекси поточних відкритих карток (не обов'язково пара)
    var openedIndices: [IndexPath] = []

    
    init() {
          carCards = createDeck()    // Створюємо колоду при запуску гри
      }
    
    
    // Створення колоди карток
    private func createDeck() -> [CarCard] {
        // Кожна кортеж містить id, назву логотипу і назву фото машини
        let cars = [
               ("bmw", "bmw_logo", "BMW_photo"),
               ("ferrari", "ferarri_logo", "Ferarri_photo"),
               ("toyota", "toyota_logo", "Toyota_photo"),
               ("aston-martin", "aston-martin_logo", "AstonMartin_photo"),
               ("honda", "honda_logo", "Honda_photo"),
               ("jaguar", "jaguar_logo", "Jaguar_photo"),
//               ("lambo", "lambo_logo", "Lamborgini_photo"),
//               ("mercedes", "mercedes_logo", "Mercedes_logo"),
//               ("nissan", "nissan_logo", "Nissan_photo"),
//               ("subaru", "subaru_logo", "Subaru_photo"),
           ]
        
        var deck = [CarCard]()
        
        for (id, logo, photo) in cars {
            // Додаємо логотип як картку
            deck.append(CarCard(id: UUID(), pairId: id, imageName: logo, isMatched: false, type: .logo))
            //  Додаємо фото машини як картку
            deck.append(CarCard(id: UUID(), pairId: id, imageName: photo, isMatched: false, type: .photo))
        }
        
        deck.shuffle()  // Перемішуємо колоду для випадкового порядку
        return deck
    }
    
    
    // Перевірка, чи дві картки утворюють пару
    func checkPair(firstIndex: IndexPath, secondIndex: IndexPath) -> Bool {
        
        let firstCard = carCards[firstIndex.row]
        let secondCard = carCards[secondIndex.row]
        
        // Пара співпадає, якщо pairId однаковий і типи різні (logo ↔ photo)
        if firstCard.pairId == secondCard.pairId && firstCard.type != secondCard.type {
            carCards[firstIndex.row].isMatched = true
            carCards[secondIndex.row].isMatched = true
            return true
        }
        return false
    }
    
    
    // Перевірка, чи всі картки знайдені
    func checkWin() -> Bool {
          return carCards.allSatisfy { $0.isMatched }   // Повертає true, якщо всі картки відкриті
      }
}


