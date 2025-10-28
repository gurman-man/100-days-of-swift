//
//  DetailViewController.swift
//  Project1
//
//  Created by mac on 31.12.2024.
//

import UIKit

class DetailViewController: UIViewController {
    var selectedPictureNumber = 0 // the number of selected image
    var totalPictures = 0 // Total amount of pictures
    var selectedImage: String?
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title  = selectedImage
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        // Do any additional setup after loading the view.
        title = "Picture \(selectedPictureNumber) of \(totalPictures)"
        
        // Download picture
        if let selectedImage = selectedImage {
            imageView.image = UIImage(named: selectedImage)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func shareTapped() {
        guard let originalImage = imageView.image else {
            print ("No image found!")
            return
        }
        
        //  Створюєм «полотно» потрібного розміру.
        let renderer = UIGraphicsImageRenderer(size: originalImage.size)
        
        let imageWithText = renderer.image { ctx in
            // Малюємо оригінальне фото
            originalImage.draw(at: .zero)   // рендерить початкове фото
            
            // Стиль тексту
            // Використовується щоб вирівняти текст по центру, керувати відступами тощо
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            // додаємо тінь
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black.withAlphaComponent(0.7)
            shadow.shadowOffset =  CGSize(width: 2, height: 2)  // зміщення тіні вправо і вниз
            shadow.shadowBlurRadius = 4
            
            // Створили словник атрибутів, що містить  шрифт, колір, вирівнювання
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 46),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.white,
                .shadow: shadow
            ]
            
            // Прямокутник для тексту (знизу)
            // готуємо область, куди малюватимемо текст — тут внизу картинки.
            let text = "From Storm Viewer"
            let textRect = CGRect(
                x: 0,
                y: 20,
                width: originalImage.size.width,    // центрує текст повністю по ширині
                height: 50
            )
            
            text.draw(in: textRect, withAttributes: attrs)
        }
        
        // JPEG-версія
        // Конвертуємо результат у JPEG
        guard let image = imageWithText.jpegData(compressionQuality: 0.9) else { return }
        
        // ЗБерігаєм ім'я зображення в змінній - imageName
        let imageName = selectedImage ?? "example.jpg"
        
        // Передаємо в масив саме зображення та його назву ([Any] - може містити об'єкт любого типу
        let activityItems: [Any] = [imageWithText, imageName]
        
        // Створюємо контроллер для обміну даних
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Забеспечуємо вигляд меню для Ipad (popover) - для показу меню дій, а не повноекранне вікно
        activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        // Показуємо контроллер
        present(activityViewController, animated: true)
    }
    
}
