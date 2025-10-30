//
//  ViewController.swift
//  Challenge2
//
//  Created by mac on 11.02.2025.
//

import UIKit

class ViewController: UITableViewController {
    
    // MARK: - Properties
    var shoppingList = [String]()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Shopping List"
        configureNavBar()
        configureButtons()
    }
    
    
    // MARK: - UI Setup
    
    // Налаштовуємо шрифт і колір заголовка
    private func configureNavBar() {
        let appearance = UINavigationBarAppearance()
        
        // Застосовуємо стилі до заголовка
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
            .foregroundColor: UIColor.systemOrange
        ]
       navigationController?.navigationBar.standardAppearance = appearance
    }
    
    // Налаштовуємо розміщення кнопок
    private func configureButtons() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareList)),   // Оголошення кнопки - share
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))         // Оголошення кнопки - додати
        ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearList))
        // Оголошення лівої кнопки - кошик
    }
    
    
    // MARK: - TableView Data Source
    
    //  Метод каже таблиці, скільки рядків показувати
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    // Метод каже таблиці, що варто писати
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = shoppingList[indexPath.row]
        return cell
    }
    
    
    // MARK: - TableView Swipe Actions
    
    // Видаляє товар з кошика
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _,_,completion in
            self.shoppingList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
    // MARK: - Actions
    
    // Додає товари до кошику
    @objc func addItem() {
        
        // Сповіщення
        let ac = UIAlertController(title: "Enter your shopping item: ", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Add", style: .default) {
            
            //          weak self →   Створює слабке посилання на self, щоб уникнути утримання ViewController в пам’яті
            //          weak ac   →   Слабке посилання на UIAlertController, щоб він міг нормально зникнути
            //          _ in      →   Каже, що параметр (UIAlertAction), який передається у замикання, ігнорується (бо він не потрібен)
            [weak self, weak ac] _ in
            
            // Дістаємо текст із першого (і єдиного) текстового поля UIAlertController інакше -
            // Якщо текст порожній (nil), метод просто вийде без дій
            guard let answer = ac?.textFields?[0].text else { return }
            
            // Додавання товару до списку
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    
    // Очищає список покупок
    @objc func clearList() {
        shoppingList.removeAll()
        tableView.reloadData()
    }
    
    
    // Ділиться списком покупок
    @objc func shareList () {
        let items = shoppingList.map { "- \($0)" }.joined(separator: "\n")  // Об'єднуємо список у текст
        let vc = UIActivityViewController(activityItems: [items], applicationActivities: nil)
        
        // Перевіряємо, чи це iPad
        if let popoverPresentationController = vc.popoverPresentationController {
            popoverPresentationController.barButtonItem = navigationItem.leftBarButtonItem
        }
        
        present(vc, animated: true)
    }
    
    // MARK: - Helpers
    
    // Метод для обробки кнопки - Add
    func submit (_ answer: String) {
        
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAnswer.isEmpty else { return } // Якщо рядок пустий, не додаємо
        
        // Наш товар додається до масиву
        shoppingList.insert(trimmedAnswer, at: 0)
        
        // Додаємо товар у таблицю
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}

