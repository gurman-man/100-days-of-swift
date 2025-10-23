//
//  ViewController.swift
//  Project5
//
//  Created by mac on 28.01.2025.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Створення кнопки +
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        // Створення кнопки нової гри
        let startGameButton = UIBarButtonItem(image: UIImage(systemName: "gamecontroller.fill"), style: .plain, target: self, action: #selector(startGame))
       
        // створення гнучкого простору
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // додаємо кнопки до гнучкого простору
        navigationItem.rightBarButtonItems = [flexibleSpace, addButton]
        navigationItem.leftBarButtonItems = [startGameButton, flexibleSpace]
        
 
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
  
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

    // Метод каже таблиці, скільки рядків показувати
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    // Метод каже таблиці, що писати у кожному рядку
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField() // додає текстове поле для введення користувачем
        
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction) // створює кнопку "Submit", яка реагує на натискання
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased() // перетворює слово в нижній регістр
        
        if !isPossible(word: lowerAnswer) {
            ShowErrorMessage(title: "Word not possible", message: "You can't spell that word from '\(title!.lowercased())'!")
            return
        }
        
        if !isOriginal(word: lowerAnswer) {
            ShowErrorMessage(title: "Word already used", message: "Be more original!")
            return
        }
        
        if !isReal(word: lowerAnswer) {
            ShowErrorMessage(title: "Word not recognized", message: "You can't just make them up, you know!" )
            return
        }

        
        usedWords.insert(lowerAnswer, at: 0) // наше слово зберіагається у usedWords
       
            
        let IndexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [IndexPath], with: .automatic) // / Додаємо рядок у таблицю
    }
        
    
    
    // Cлово яке можна скласти з букв основного слова (title)
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position) // Якщо буква є в tempWord, вона видаляється, щоб не використовувати її двічі
            } else {
                return false
            }
        }
        return true
    }
    
    
    // Cлово ще не використане
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    
    // Cправжнє слово (існує в словнику)
    func isReal(word: String) -> Bool {
        
        // Перевіряємо, чи слово має хоча б 3 літери
        if word.count < 3 {
            ShowErrorMessage(title: "Word too short", message: "Your word must be at least 3 letters long.")
            return false
        }
        
        // Перевіряємо, чи слово не є стартовим
        if word == title?.lowercased() {
            ShowErrorMessage(title: "Word is the start word", message: "You can't just use the starting word!")
            return false
        }
        
        let checker = UITextChecker() // клас для виявлення орфографічних помилок
        let range = NSRange(location: 0, length: word.utf16.count) // зберігання діапазону символів рядка
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en") // перевіряє, чи є слово вбудованим у словник iOS
        
        return misspelledRange.location == NSNotFound
    }
    
    // Метод  для показу сповіщення про помилку
    func ShowErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac,animated: true)
    }
}
