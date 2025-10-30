//
//  ViewController.swift
//  Notes
//
//  Created by mac on 02.07.2025.
//

import UIKit

class ViewController: UITableViewController {
    var notes = [Note]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        tableView.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.99)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        // Cтворення кнопки - ʼменюʼ
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(showMenu))
        
        // Cтворення кнопки - ʼнова нотаткаʼ
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action:  #selector(addNote))
        
        // Отримання даних нотаток
        loadNotes()
        
        if notes.isEmpty {
            notes.append(Note(text: "First Note\nDetails", date: Date(), id: UUID()))
            notes.append(Note(text: "Second Note\nExtra details", date: Date(), id: UUID()))
        }
    }
    
    
    @objc func showMenu() {
        let ac = UIAlertController(title: "Choose option", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Sort by date", style: .default) { [weak self] _ in
            self?.notes.sort { $0.date > $1.date }
            self?.tableView.reloadData()
        })
        
        ac.addAction(UIAlertAction(title: "Delete All", style: .destructive) { [weak self] _ in
            self?.confirmDeleteAll()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func confirmDeleteAll(){
        let ac = UIAlertController(title: "Delete all notes?", message: "This action cannot be canceled!", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.notes.removeAll()
            self?.tableView.reloadData()
            self?.saveNotes()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    @objc func addNote() {
        let note = Note(text: "", date: Date(), id: UUID())
        notes.append(note)
        
        let index = notes.count - 1
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as! DetailViewController
        vc.note = note
        
        vc.onSave = { [weak self] updatedNote in
            guard let self = self else { return }
            
            if let updatedNote = updatedNote{
                self.notes[index] = updatedNote
            } else {
                // Якщо користувач видалив нотатку в DetailViewController
                self.notes.remove(at: index)
            }
            
            self.tableView.reloadData()
            self.saveNotes()
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        
        let note = notes[indexPath.row]
        
        // Витягуємо перший рядок нотатки
        let firstLine = note.text.components(separatedBy: "\n").first ?? ""
        
        // Форматуємо дату
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        cell.textLabel?.text = firstLine
        cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 22)
        cell.textLabel?.textColor = .white
        
        cell.detailTextLabel?.text = formatter.string(from: note.date)
        cell.detailTextLabel?.font =  UIFont(name: "Noteworthy-Bold", size: 12)
        cell.detailTextLabel?.textColor = UIColor.white.withAlphaComponent(0.7)
        
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        cell.layer.borderWidth = 5
        cell.layer.borderColor = UIColor.systemIndigo.cgColor
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        cell.selectionStyle = .none
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1. Створюємо DetailViewController
        let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as! DetailViewController
        
        // 2. Отримуємо обрану нотатку
        let selectedNote = notes[indexPath.row]
        
        vc.note = selectedNote
        
        // 4. (Опційно) передаємо замикання для оновлення після редагування
        vc.onSave = { [weak self] updatedNote in
            guard let self = self else { return }
            if let updatedNote = updatedNote {
                self.notes[indexPath.row] = updatedNote
            } else {
                self.notes.remove(at: indexPath.row)
            }
            self.tableView.reloadData()
            self.saveNotes()
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadNotes() {
        // Отримання даних з UserDefaults
        let defaults = UserDefaults.standard
        
        // Перевірка на наявність даних
        if let savedNotes = defaults.object(forKey: "notes") as? Data {
            // Спроба декодувати [Note]
            let jsonDecoder = JSONDecoder()
            do {
                notes = try jsonDecoder.decode([Note].self, from: savedNotes)
            } catch {
                print("Failed to load notes.")
            }
        }
    }
    
    
    func saveNotes() {
        let jsonEncoder = JSONEncoder()
        // Спроба закодувати [Note] у Data
        if let savedData = try? jsonEncoder.encode(notes) {
            // Збереження результату в UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "notes")
        }  else {
            print("Failed to save notes.")
        }
    }
    
    // Дозволити видалення з таблиці свайпом
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveNotes()
        }
    }
}

