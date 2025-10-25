//
//  ViewController.swift
//  Project13
//
//  Created by mac on 23.05.2025.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var radius: UISlider!
    
    
    @IBOutlet var changeFilterButton: UIButton!
    var currentImage: UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "INSTAFILTER"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        // встановлюємо наше поточне зображення як зображення, щоб мати копію імортованого зобрааження
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProccesing()
    }
    
    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISRGBToneCurveToLinear", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            // sourceView вказує, з якої візуальної компоненти (UIButton) має з'являтись поповер
            popoverController.sourceView = sender
            // sourceRect — прямокутна область в межах sourceView, з якої виринає поповер
            // sender.bounds означає всю площу кнопки
            popoverController.sourceRect = sender.bounds
        }
                     
        present(ac, animated: true)
    }
    
    func setFilter(action: UIAlertAction) {
        // Переконаємось чи наше зображення існує
        guard currentImage != nil else { return }
        
        // Безпечно зчитаємо title сповіщення
        guard let actionTitle = action.title else { return }
        
        // - Створює новий фільтр за назвою, яку вибрав користувач. Наприклад: CIFilter(name: "CIPixellate").
        currentFilter = CIFilter(name: actionTitle)
        
        // — Перетворює зображення (UIImage) у формат CIImage, який потрібен для Core Image фільтрів
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        // - Змінюєм заголовок кнопки - відповідно до вибраного фільтру
        changeFilterButton.setTitle(actionTitle, for: .normal)
        
        applyProccesing()
    }
    
    @IBAction func save(_ sender: Any) {
        
        if imageView.image == nil {
            let ac = UIAlertController(title: "Ooops...", message: "Image not found!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            // якщо зображення є — зберігаємо
            guard let image = imageView.image else { return }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_: didFinishSavingError:contextInfo:)), nil)
        }
    }
    
    @IBAction func intesityChanged(_ sender: Any) {
        applyProccesing()
    }
    
    @IBAction func radiusChanged(_ sender: UISlider) {
        applyProccesing()
    }
    
    func applyProccesing() {
        // Тут працює один активний фільтр (currentFilter).
        // Ми просто перевіряємо, які вхідні параметри він підтримує, і встановлюємо їх значення через слайдери.
        // Такий підхід дозволяє працювати з різними типами фільтрів (одні мають радіус, інші — інтенсивність, деякі — обидва) без помилок.
        
        let inputKeys = currentFilter.inputKeys
        
        // Перевіряє, які параметри підтримує фільтр:
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        
        // context.createCGImage(... створює CGImage з CIImage)  — виконує рендеринг CIImage у піксельні дані
        // .extent — це розміри обробленого зображення
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            
            // Створює UIImage з CGImage. Це реальне зображення з пікселями, яке можна безпомилково відображати.
            // Встановлює оброблене зображення у UIImageView
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your alerted image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
}

