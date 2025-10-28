//
//  ViewController.swift
//  Project28
//
//  Created by mac on 12.08.2025.
//

import UIKit
import LocalAuthentication      // Це фреймворк, який дає доступ до Touch ID та Face ID

class ViewController: UIViewController {
    @IBOutlet var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        // Якщо пароль ще не збережений - створюєм
        if getPassword() == nil {
            askForNewPassword()
        }
    
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector:  #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //  підписуємось на нотифікації (системні повідомлення) про стан клавіатури:
        //  - keyboardWillHideNotification — клавіатура зникне
        //  - keyboardWillChangeFrameNotification — клавіатура змінить розмір або з’явиться
        
        
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        // збереження при виході з програми
    }
    
    
    // Кнопка для розблокування
    @IBAction func authenicateTapped(_ sender: Any) {
        let context = LAContext()
        var error:  NSError?
        
        // Перевіряє, чи можлива біометрична автентифікація
        // &error — передається як вказівник, щоб Objective-C API міг заповнити його інформацією про помилку.
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"   // Пояснює користувачу причину
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)  { [weak self] success, authenicationError in
                DispatchQueue.main.async {
                    // Якщо успіх → викликає unlockSecretMessage()
                    if success {
                        self?.unlockSecretMessage()
                    // Якщо помилка → показує UIAlertController з повідомленням
                    } else {
                        // error
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not verified; please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        ac.addAction(UIAlertAction(title: "Use password", style: .default) { _ in
                            self?.showPasswordPrompt()
                        })
                        self?.present(ac, animated: true)
                    }
                }
            }
            // Обробка випадку без біометрії
        } else {
            // no biometry
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction  (title: "OK", style: .default))
            present(ac, animated: true)
        }
        
    }
    
    
    // Метод, який змінює відступи UITextView, коли з’являється або зникає клавіатура.
    // Він налаштовує так, щоб при появі або зникненні клавіатури UITextView автоматично підлаштовувався — текст і курсор завжди були видимими, а індикатор прокрутки не ховався.
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
         
        let keyboardScreenEnd = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    
    // Відкриття секретного повідомлення
    func unlockSecretMessage() {
        secret.isHidden = false     // Робимо UITextView видимим.
        title = "Secret stuff!"     // Міняємо заголовок, щоб користувач бачив, що він розблокував секрет.
        
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
        // Завантажуємо текст із Keychain (а не з UserDefaults).
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(lockSecretMessage))
    }
    
    
    // Збереження секрету
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }
        // - зберігаємо тільки якщо поле було видиме
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        // — зберігаємо текст у Keychain (система його автоматично шифрує)
        
        secret.resignFirstResponder()
        // — ховаємо клавіатуру
        
        secret.isHidden = true
        // — ховаємо поле з текстом
        
        title = "Nothing to see here"
        // — повертаємо невинний заголовок
    }
    
    
    // Блокування секрету
    @objc func lockSecretMessage() {
        navigationItem.rightBarButtonItem = nil
        // Прибираємо кнопку
        
        saveSecretMessage()
        // Зберігаємо дані
    }
    
    
    func showPasswordPrompt() {
        let alert = UIAlertController(title: "Enter password", message: nil, preferredStyle: .alert)
        alert.addTextField() { textField in
            textField.placeholder = "Your password"
            textField.isSecureTextEntry = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak alert] _ in
            guard let password = alert?.textFields?.first?.text else { return }
            
            if let savedPassword = self?.getPassword(), savedPassword == password {
                self?.unlockSecretMessage()
            } else {
                let ac = UIAlertController(title: "Wrong password", message: "The password you entered is incorrect.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(ac, animated: true)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(submitAction)
        present(alert, animated: true)
    }
    
    
    // Зберерігаємо пароль у Keychain
    func savePassword(_ password: String) {
        KeychainWrapper.standard.set(password, forKey: "AppPassword")
    }
    
    func getPassword() -> String? {
        KeychainWrapper.standard.string(forKey: "AppPassword")
    }
    
    func askForNewPassword() {
        let alert = UIAlertController(title: "Set Password", message: "Create a fallback password for Face ID / Touch ID", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "Enter password"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            if let password = alert?.textFields?.first?.text, !password.isEmpty {
                self?.savePassword(password)
            }
        })
        
        present(alert, animated: true)
    }

}

