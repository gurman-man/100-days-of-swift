//
//  ViewController.swift
//  MemeGenerationApp
//
//  Created by mac on 10.08.2025.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    
    // Змінні для збереження введеного користувачем тексту
    var topText: String?
    var bottomText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // NAVIGATION BAR
        navigationController?.navigationBar.tintColor = .systemIndigo
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Import Picture", style: .plain, target: self, action: #selector(importPicture))
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButton))
        navigationItem.rightBarButtonItem = shareButton
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemIndigo,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        
        
        // TOOL BAR
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let setBottomButton = UIBarButtonItem(title: "Set Bottom Text", style: .plain, target: self, action: #selector(setBottomButton))
        let setTopButton = UIBarButtonItem(title: "Set Top Text", style: .plain, target: self, action: #selector(setTopButton))
        
        toolbarItems = [setBottomButton, flexibleSpace, setTopButton ]
        navigationController?.isToolbarHidden = false
    }
    
    
    // MARK: OBJC METHODDS
    @objc func importPicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        label.isHidden = true
        present(imagePicker, animated: true)
    }
    
    
    @objc func shareButton() {
        guard let image = imageView.image else {
            let alert = UIAlertController(title: "No image", message: "Please import a picture first.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
               return
        }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        // applicationActivities - кастомнs дії
        
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
    
    
    @objc func setBottomButton() {
        showTextInputAlert(title: "Bottom Text", message: "Enter the text you want to appear at the bottom of the meme") { [weak self] text in
            // введений текст збережеться я у bottomText
            self?.bottomText = text.isEmpty ? nil : text
            // для перерисовки картинки з новим текстом
            self?.updateImageWithText()
        }
    }
    
    
    @objc func setTopButton() {
        showTextInputAlert(title: "Top Text", message: "Enter the text you want to appear at the top of the meme") { [weak self] text in
            self?.topText = text.isEmpty ? nil : text
            self?.updateImageWithText()
        }
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            topText = nil
            bottomText = nil
            label.isHidden = false
        }
        label.isHidden = imageView.image != nil
        dismiss(animated: true)
        // Закриває UIImagePickerController після вибору зображення
    }
    
    
    // Функція рендерингу нового зображення з текстом
    func updateImageWithText() {
        // Перевірка, чи є картинка в imageView
        guard let originalImage = imageView.image else { return }
        
        let renderer = UIGraphicsImageRenderer(size: originalImage.size)
        let newImage = renderer.image { ctx in
            originalImage.draw(at: .zero)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Impact", size: originalImage.size.height * 0.08) ?? UIFont.boldSystemFont(ofSize: originalImage.size.height * 0.08),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -3,
                .paragraphStyle: paragraphStyle
            ]
            
            // Відступи від країв (у пікселях картинки)
            let verticalPadding: CGFloat = originalImage.size.height * 0.05
            let textHeight: CGFloat = originalImage.size.height * 0.1
            let horizontalPadding: CGFloat = originalImage.size.width * 0.05 // 5% від ширини картинки
            
            // Якщо є topText
            if let top = topText {
                let topRect = CGRect(
                    x: horizontalPadding,
                    y: verticalPadding,
                    width: originalImage.size.width - 2 * horizontalPadding,
                    height: textHeight
                )
                top.draw(in: topRect, withAttributes: attributes)
            }
            
            // Якщо є bottomText
            if let bottom = bottomText {
                let bottomRect = CGRect(
                    x: horizontalPadding,
                    y: originalImage.size.height - textHeight - verticalPadding,
                    width: originalImage.size.width - 2 * horizontalPadding,
                    height: textHeight
                )
                bottom.draw(in: bottomRect, withAttributes: attributes)
            }
        }
        // Зберігаємо нове зображення в imageView.image, замінюючи старе.
        imageView.image = newImage
    }
    
    
    // Допоміжна функція для показу alert:
    func showTextInputAlert (title: String, message: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // перевіряє, чи є текст, і якщо так, викликає completion (замикання) з цим текстом
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let text = alert.textFields?.first?.text ?? ""
            completion(text)
            // Завжди викликаємо completion, навіть якщо текст пустий
        }))
        
        present(alert, animated: true)
    }
}

