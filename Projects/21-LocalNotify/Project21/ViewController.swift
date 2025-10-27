//
//  ViewController.swift
//  Project21
//
//  Created by mac on 28.06.2025.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
    }
    
    // Метод для запиту дозволу на показ сповіщень
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        // Запитуємо дозвіл на показ alert, значків і звуків
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted,
            error in
            if granted {
                print("Yay!")   // Дозвіл отримано
            } else {
                print("D'oh!")  // Дозвіл відхилено
            }
        }
    }
    
    // Метод для планування сповіщення
    @objc func scheduleLocal() {
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        
        // Видаляємо всі заплановані сповіщення перед створенням нового
        center.removeAllPendingNotificationRequests()
        
        // Створюємо вміст сповіщення
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"            // Категорія для можливих дій
        content.userInfo = ["customData" : "fizzbuzz"]  // Додаткові дані
        content.sound = .default
        
        // Варіант 1: сповіщення за часом (приклад — кожного дня о 10:30)
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Варіант 2: сповіщення через 5 секунд
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // Створюємо запит на сповіщення з унікальним ідентифікатором
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Додаємо сповіщення до центру сповіщень
        center.add(request)
    }
    
    
    // Реєструємо кастомні дії для сповіщень
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // Дія — кнопка "Tell me more..."
        let show = UNNotificationAction(identifier: "Show", title: "Tell me more...", options: .foreground)
        
        // Друга дія — "Remind me later"
        let remind = UNNotificationAction(identifier: "RemindLater", title: "Remind me later", options: [])
           
        // Категорія "alarm" містить цю дію
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remind], intentIdentifiers: [], options: [])
        
        // Реєструємо категорію в системі
        center.setNotificationCategories([category])
    }
 
    
    // Обробка натискання на сповіщення або дію
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                //  Користувач просто натиснув на сповіщення
                let ac = UIAlertController(title: nil, message: "You have opened a notification!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                
                print("Default identifier")
                
            case "Show":
                // Користувач натиснув "Tell me more..."
                let ac = UIAlertController(title: nil, message: "Here is more information...", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                
                print("Show more iformation...")
                
            case "RemindLater":
                // Користувач натиснув "Remind me later"
                scheduleReminder()
                
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    // Планує сповіщення через 24 години.
    func scheduleReminder() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call (reminder)"
        content.body = "This is your reminder – wake up call again!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData" : "reminder"]
        content.sound = .default
        
        // 86400 секунд = 24 години
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
        
        print("🔁 Reminder scheduled for 24 hours later")
    }

    
    
    // Показує сповіщення навіть якщо додаток активний
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge]) // показуємо сповіщення як банер
    }
}

