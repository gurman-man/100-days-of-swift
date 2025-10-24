//
//  ViewController.swift
//  Project10
//
//  Created by mac on 30.04.2025.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Кожен елемент зберігає ім’я та шлях до зображення.
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Додає кнопку "+" у навігаційний бар.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }
    
    
    // повертає кількість елементів
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    
    // Це основний метод для налаштування кожної комірки в колекції.
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Уникає створення нових комірок для кожного елементу і дозволяє повторно використовувати вже створені комірки, що покращує продуктивність.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            // Використовується для термінового припинення роботи програми, якщо кастинг не вдалося, що допомагає виявити проблеми в налаштуваннях швидко.
            fatalError("Unable tp dequeue PersonCell.")
        }
        
        // Тепер комірка заповнюється даними з об’єкта Person
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        // Шлях до зображення створюється з папки Documents
        let path = getDocumentDirectory().appendingPathComponent(person.image)
        // Завантаження картинки відбувається з файлової системи, а не з активної памʼяті
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    
    @objc func addNewPerson() {
        let alert = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self ] _ in
            
            //  Цей рядок потрібно, щоб безпечно розгорнути слабку (weak) ссилку. Якщо контролер вже знищено з памʼяті, self буде nil, і код далі не виконається
            guard let self = self else { return }
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                // Відкриває камеру, щоб зробити нове фото.
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker,animated: true)
            } else {
                let errorAlert = UIAlertController(title: "Camera not available", message: nil, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            let picker = UIImagePickerController()
            // Відкриває фотогалерею, де можна вибрати вже існуюче фото.
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        // Генеруємо унікальне ім’я файлу через UUID.
        let imageName = UUID().uuidString
        let imagePath  = getDocumentDirectory().appendingPathComponent(imageName)
        
        // Зберігаємо зображення у JPEG-форматі локально на пристрої.
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        
        // Оновлюємо колекціюQ
        collectionView.reloadData()
        
        // Закриває UIImagePickerController після вибору зображення
        dismiss(animated: true)
    }
    
    
    // Повертає шлях до Documents-каталогу — безпечне місце для збереження даних у додатку
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Отримуємо об’єкт Person зі списку people, який відповідає вибраному елементу
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] _ in
            // Отримуємо введений текст із першого (єдиного) поля
            guard let newName = ac?.textFields?[0].text else { return }
            
            // Змінюємо ім’я об’єкта Person
            person.name = newName
            
            // Оновлюємо інтерфейс, щоб нове ім’я зʼявилось на екрані.
            self?.collectionView.reloadData()
        }))
        
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.people.remove(at: indexPath.item)
            self?.collectionView.reloadData()
            
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}
