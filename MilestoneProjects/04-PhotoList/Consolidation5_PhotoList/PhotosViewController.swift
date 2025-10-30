//
//  ViewController.swift
//  Consolidation5_PhotoList
//
//  Created by mac on 14.05.2025.
//

import UIKit

class PhotosViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Додав заголовок
        title = "Photo List"
        navigationController?.navigationBar.prefersLargeTitles = true
    
        
        // Додай кнопку "+", щоб додавати нові фото
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto))
        
        
        // Додали кнопку "Clear", щоб очищати фото
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(clearPhotos))
        
        
        // Колір навігаційної панелі та заголовка
        navigationController?.navigationBar.tintColor = .systemPink
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.systemPurple]
        
        
        // Завантажуєм фото у проект
        loadPhotos()
        
    }
    
    @objc func addPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        
    }
    
    @objc func clearPhotos() {
        photos.removeAll() // очищає масив
        UserDefaults.standard.removeObject(forKey: "photos") // видаляє збереження
        tableView.reloadData() // оновлює таблицю
    }
    
    // Повертає шлях до Documents-папки — безпечне місце для збереження даних у додатку
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 1. Отримуємо зображення
        guard let image = info[.originalImage] as? UIImage else { return }
        
        // 2. Генеруємо ім’я файлу для збереження
        let imageName = UUID().uuidString
        let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
        
        // 3. Зберігаємо фото в документи
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            //  Записуєш зображення у файл
            try? jpegData.write(to: imagePath)
        }
        
        // Закриваєш Image Picker
        dismiss(animated: true) {
            // 5. Показуємо UIAlertController після закриття
            let ac = UIAlertController(title: "Caption for photo", message: nil, preferredStyle: .alert)
            ac.addTextField()
            
            // 6. Дія "ОК" — тут створюємо об'єкт Photo
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                guard let caption = ac.textFields?.first?.text else { return }
                
                // 7. Створюємо Photo
                let newPhoto = Photo(imageName: imageName, imageCaption: caption)
                
                // 8. Додаємо в масив
                self?.photos.append(newPhoto)
                
                // 9. Зберігаємо через UserDefaults
                self?.savePhotos()
                
                // 10. Оновлюємо таблицю
                self?.tableView.reloadData()
            })
            
            ac.addAction(okAction)
            self.present(ac, animated: true)
        }
    }
    
    
    func loadPhotos() {
        let defaults = UserDefaults.standard
        
        if let savedData = defaults.data(forKey: "photos") {
            let decoder = JSONDecoder()
            if let savedPhotos = try? decoder.decode([Photo].self, from: savedData) {
                photos = savedPhotos
            }
        }
    }
    
    func savePhotos() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        if let save = try? encoder.encode(photos) {
            defaults.set(save, forKey: "photos")
        } else {
            print("Failed to save photos.")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {
            fatalError("Unable to dequeue PhotoCell")
        }
        
        let photo = photos[indexPath.row]
        
        cell.captionLabel.text = photo.imageCaption
        let path = getDocumentDirectory().appendingPathComponent(photo.imageName)
        cell.photoImageView?.image = UIImage(contentsOfFile: path.path)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Detele") { _,_, completion in
            self.photos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.savePhotos()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //  обробка, коли користувач натискає на осередок таблиці
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImageName = photos[indexPath.row].imageName
            vc.selectedCaption = photos[indexPath.row].imageCaption   // передаємо підпис
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

