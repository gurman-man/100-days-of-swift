//
//  MyScriptsViewController.swift
//  Extension
//
//  Created by mac on 21.06.2025.
//

import UIKit

class MyScriptsViewController: UITableViewController {
    
    // Масив скриптів, передається з ActionViewController
    var scripts: [Script] = []
    // Замикання для передачі вибраного скрипта назад
    var onSelectScript: ((Script) -> Void)?
    
    var onScriptsChanged: (([Script]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "📜 My Scripts"
        
        // Кнопка "Додати скрипт"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScript))
        
        // Кнопка "Закрити"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ScriptCell")
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scripts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScriptCell", for: indexPath)
        cell.textLabel?.text = scripts[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Отримуємо вибраний скрипт із масиву scripts за його індексом (indexPath.row)
        let selectedScript = scripts[indexPath.row]
        
        // коли користувач вибирає скрипт у таблиці, викликається це замикання, і текст скрипта вставляється у головне текстове поле UITextView.
        onSelectScript?(selectedScript) // ??
        
        // Закриває поточний екран
        dismiss(animated: true)
    }
    
    // MARK: - Додавання нового скрипта
    @objc func addScript() {
        let ac = UIAlertController(title: "New script:", message: "Enter name and code of script", preferredStyle: .alert)
        ac.addTextField() { $0.placeholder = "Name" }
        ac.addTextField() { $0.placeholder = "JavaScript cod" }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak ac] _ in
            guard let name = ac?.textFields?[0].text, !name.isEmpty,
                  let code = ac?.textFields?[1].text, !code.isEmpty else { return }
            
            let newScript = Script(name: name, code: code)
            self?.scripts.append(newScript)
            self?.tableView.reloadData()
            
            // Збереження в UserDefaults
               let jsonEncoder = JSONEncoder()
               if let savedData = try? jsonEncoder.encode(self?.scripts) {
                   UserDefaults.standard.set(savedData, forKey: "scripts")
               }
            
            // Якщо потрібно, повідом ActionViewController
            self?.onScriptsChanged?(self?.scripts ?? [])
        }
        
        ac.addAction(saveAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    // MARK: - Закриття вікна
        @objc func dismissSelf() {
            dismiss(animated: true)
        }
}
