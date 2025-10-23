//
//  ViewController.swift
//  Project2
//
//  Created by mac on 03.01.2025.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswear = 0
    var questionCount = 0
    var finalscore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "UK", "US"]
        view.backgroundColor = UIColor(named: "Gorgeous")
        
        
        // Налаштування кнопок
        setupButtons()
        
        
        // Створення кнопки, що відображає рахунок
        let scoreButton = UIBarButtonItem(title: "Score: \(score)", style: .plain, target: self, action: #selector(showScore))
        // Додаємо кнопку до правої частини навігаційної панелі
        self.navigationItem.rightBarButtonItem = scoreButton

        askQuestion(action: nil)
            }
    
    @objc func showScore() {
        // Створення та відобраєення повідомлення
        let alert = UIAlertController(title: "Score: \(score)", message: "You have \(score) points!", preferredStyle: .alert)
        
        // Додається додаткова кнопка для сповіщення
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    // Функція для налаштування вигляду кнопок
    func setupButtons() {
        [button1, button2, button3].forEach { button in
            button?.layer.borderColor = UIColor.lightGray.cgColor
            button?.layer.cornerRadius = 10
            button?.layer.borderWidth = 2
            button?.clipsToBounds = true
        }
    }
    
    
    func askQuestion(action: UIAlertAction!) {
        countries.shuffle()
        correctAnswear = Int.random(in: 0...2)
        
        // Прив'язка зображень до кнопок
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        // Установлення заголовку (назва країни)
        title = countries[correctAnswear].uppercased()
    }
    
    
    // Оновлення рахунку
    func updateScore() {
        if let scoreButton = self.navigationItem.rightBarButtonItem{
            scoreButton.title = "Score: \(score)"
        }
    }
    
    
    // Завершення гри
    func gameOver() {
        // Створення end - сповіщення про закнічення гри
            let alert = UIAlertController(
                title: "Game over",
                message: "You answered \(questionCount) questions.\nYour final score is \(finalscore).\nSee you next time!",
                preferredStyle: .alert)
            
        // Кнопка для початку нової гри
        alert.addAction(UIAlertAction(title: "Restart", style: .default) { _ in
            
            self.score = 0
            self.questionCount = 0
            self.finalscore = 0
            
            self.updateScore()
            
            self.askQuestion(action: nil)
        })
        
        // Відображення end - сповіщення
            present(alert, animated: true)
    }
    
    
    // Обробка натискання кнопок
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        
        // Анімували прапори з відскоком при натисканні
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            sender.transform = .identity
        })
        
        if sender.tag == correctAnswear {
            title = "Correct!"
            score += 1
            finalscore = score // Підсумковий рахунок змінюється після кожного запитання
        } else {
            // Відобаження правильної назви країни
            let countryName = countries[sender.tag].uppercased()
            title = "Wrong! That's the flag of \(countryName)"
            score -= 1
        }
        
        questionCount += 1
        updateScore()
        
        // Перевірка на закінчення гри
        if questionCount == 10 { gameOver() }
        
        // Відображення сповіщення
        let ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
        
        // Додавання дії (кнопки)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        
        // Відображення сповіщення
        present(ac, animated: true)
    }
}

