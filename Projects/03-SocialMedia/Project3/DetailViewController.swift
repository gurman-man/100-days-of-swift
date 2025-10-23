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
        // Inspection, if there is an image and conversion to JPEC format
        guard let image = imageView.image?.jpegData(compressionQuality: 0.9) else {
            print ("No image found!")
            return
        }
        
        // ЗБерігаєм ім'я зображення в змінній - imageName
        let imageName = selectedImage ?? "example.jpg"
        
        // Передаємо в масив саме зображення та його назву ([Any] - може містити об'єкт любого типу
        let activityItems: [Any] = [image, imageName]
        
        // Створюємо контроллер для обміну даних
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Забеспечуємо вигляд меню для Ipad (popover) - для показу меню дій, а не повноекранне вікно
        activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        // Показуємо контроллер
        present(activityViewController, animated: true)
    }
}
