//
//  ViewController.swift
//  Memory-Pairs
//
//  Created by mac on 27.08.2025.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel = CarGameViewModel()  // Модель гри, де зберігаються всі картки та логіка
    private var gradientLayer: CAGradientLayer? // Фон у вигляді градієнта
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Memory Pairs"
        let wideColor = UIColor(displayP3Red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        
        view.backgroundColor = wideColor   // Фоновий колір на випадок, якщо градієнт не завантажиться
        
        setupBackground()                   // Налаштовуємо градієнтний фон
        collectionView.dataSource = self    // Підключаємо джерело даних CollectionView
        collectionView.delegate = self      // Підключаємо делегат для обробки натискань
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds  // Підлаштовуємо градієнт під поточний розмір екрана
    }
    
    
    // Функція для налаштування background
    private func setupBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.darkGray.cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0, y: 0)       // Початок градієнта
        gradient.endPoint = CGPoint(x: 0.5, y: 1)       // Кінець градієнта
        
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.layer.addSublayer(gradient)
        collectionView.backgroundView = backgroundView  // Присвоюємо градієнт CollectionView
        
        gradientLayer = gradient
    }
    
    
    // Функція для анімації перевороту картки
    private func flipCell(_ cell: CarCell, at indexPath: IndexPath,  faceUp: Bool) {
        let card = viewModel.carCards[indexPath.row]        // Вибираємо картку
        
        UIView.transition(with: cell.contentView,           // Анімація для всього вмісту клітинки
                          duration: 0.4,
                          options: [.transitionFlipFromLeft],
                          animations: {
            cell.configure(with: card, isFaceUP: faceUp)    // Перевіряємо, що показати (фронт або тильна сторона)
        })
    }
    
    
    // Анімація для карток, які збіглися
    private func animateMatchedCards(at indices: [IndexPath]) {
        for indexPath in indices {
            if let cell = collectionView.cellForItem(at: indexPath) as? CarCell {
                UIView.animate(withDuration: 0.2,
                               animations: {
                    cell.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) // Збільшення картки
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        cell.transform = CGAffineTransform.identity         // Повертаємо нормальний розмір
                    }
                })
            }
        }
    }
    
    
    // Повідомлення про перемогу
    private func showWinAlert() {
        let alert = UIAlertController(title: "You Win!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


// MARK: - UICollectionView
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    // метод що відповідає за кількість клітинок (елементів) у конкретному розділі (section)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.carCards.count
    }
    
    
    // Налаштування клітинки
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Безпечне повернення порожньої клітинки, якщо кастинг не вдався
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarCell", for: indexPath) as? CarCell else { return UICollectionViewCell()
        }
        
        // Вибір картки
        let card = viewModel.carCards[indexPath.row]
        
        // Визначення стану картки
        // isFaceUp – чи повинна картка бути відкритою.
        let isFaceUp = card.isMatched || viewModel.openedIndices.contains(indexPath)
        
        // Встановлює зображення машини або логотипу і ховає/показує фон (
        cell.configure(with: card, isFaceUP: isFaceUp)
        return cell
    }
    
    
    // Обробка натискання на клітинку
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = viewModel.carCards[indexPath.row]
        
        // Якщо карта вже відкрита або знайдена — нічого не робимо
        guard !card.isMatched, !viewModel.openedIndices.contains(indexPath) else { return }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CarCell {
            flipCell(cell, at: indexPath, faceUp: true) // Перевертаємо картку
        }
        
        viewModel.openedIndices.append(indexPath)       // Додаємо індекс відкритої картки
        
        // Якщо відкрито дві картки
        if viewModel.openedIndices.count == 2 {
            let firstIndex = viewModel.openedIndices[0]
            let secondIndex = viewModel.openedIndices[1]
            
            // Перевірка на пару
            if viewModel.checkPair(firstIndex: firstIndex, secondIndex: secondIndex) {
                animateMatchedCards(at: [firstIndex, secondIndex])  // Анімація для правильних пар
                viewModel.openedIndices.removeAll() // Очищуємо відкриті індекси
                if viewModel.checkWin() {
                    showWinAlert()  // Якщо всі пари знайдені, показуємо alert
                }
            } else {
                // Неправильна пара — перевертаємо назад через 1 секунду
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let firstCell = collectionView.cellForItem(at: firstIndex) as? CarCell {
                        self.flipCell(firstCell, at: firstIndex, faceUp: false)
                    }
                    if let secondCell = collectionView.cellForItem(at: secondIndex) as? CarCell {
                        self.flipCell(secondCell, at: secondIndex, faceUp: false)
                    }
                    self.viewModel.openedIndices.removeAll()    // Очищаємо
                }
            }
        }
    }
    
}

