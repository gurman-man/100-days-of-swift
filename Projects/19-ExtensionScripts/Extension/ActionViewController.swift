//
//  ActionViewController.swift
//  Extension
//
//  Created by mac on 18.06.2025.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import UniformTypeIdentifiers

class ActionViewController: UIViewController {
    
    // Підключення до текстового поля, де користувач може ввести або змінити JavaScript-код
    @IBOutlet var script: UITextView!
    
    // Змінні для зберігання назви сторінки та URL, які передаються з Safari
    var pageTitle = ""
    var pageURL = ""
    
    var scripts: [Script] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DONE кнопка справа
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(done))
        
        // Меню з двома діями: My scripts та Bookmarks
        let menu = UIMenu(title: "", children: [
            UIAction(title: "📜 My scripts", image: UIImage(systemName: "doc.plaintext")) { [weak self] _ in
                self?.showMyScripts()
            },
            UIAction(title: "Basic scripts", image: UIImage(systemName: "list.bullet.rectangle")) { [weak self] _ in
                self?.chooseScript()
            }
        ])
        
        // Кнопка ліворуч з меню
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            menu: menu
        )
        
        loadScripts()
        
        // Отримуємо NotificationCenter, який надсилає системні повідомлення
        let notificationCenter = NotificationCenter.default
        
        // Підписуємось на повідомлення про ЗНИКНЕННЯ клавіатури
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Підписуємось на повідомлення про ЗМІНУ фрейму клавіатури
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // 📨 Отримуємо дані, які були передані з JavaScript через Action.js
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                // Читаємо словник типу Property List (plist)
                itemProvider.loadItem(
                    forTypeIdentifier: UTType.propertyList.identifier,
                    options: nil
                ) { [weak self] (item, error) in
                    // Перевіряємо, чи це словник
                    guard let itemDictionary = item as? NSDictionary else { return }
                    
                    // Витягуємо JavaScript-передані значення (title та URL)
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    // Зберігаємо дані в локальні змінні
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    // Оновлюємо інтерфейс на головному потоці
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                        print("✅ Title: \(self?.pageTitle ?? "none")")
                        print("🌐 URL: \(self?.pageURL ?? "none")")
                        
                        // Отримай домен (host) з URL сторінки — це буде ключ для збереження і зчитування
                        if let host = self?.hostFromURL() {
                            // Отримай доступ до UserDefaults — це локальне сховище для простих даних на пристрої.
                            let defaults = UserDefaults.standard
                            
                            // Спробуй отримати значення з UserDefaults за цим ключем:
                            // Якщо воно є — це збережений скрипт для цього сайту.
                            // Якщо значення немає — це означає, що скрипт ще не збережений для цього сайту.
                            if let savedScript = defaults.string(forKey: host) {
                                self?.script.text = savedScript
                                print("📥 Script loaded for \(host)")
                            } else {
                                print("📭 No saved script for \(host)")
                            }
                        }
                    }
                }
            }
        }
    }

    // 🧾 Метод, який викликається при натисканні кнопки "Готово"
    @objc func done() {
        // Створюємо новий елемент розширення
        let item = NSExtensionItem()
        
        // Створюємо словник з ключем "customJavaScript" і текстом з UITextView
        let argument: NSDictionary = ["customJavaScript": script.text ?? ""]
        
        // Обертаємо наш словник у ще один, із спеціальним ключем, очікуваним системою
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        
        // Обертаємо все у NSItemProvider з правильним типом
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: UTType.propertyList.identifier)
        
        // Призначаємо як вкладення до розширення
        item.attachments = [customJavaScript]
        
        save()
        
        // Повертаємо результат Safari, щоб він міг обробити змінений JavaScript
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    
    @objc func chooseScript() {
        let ac = UIAlertController(title: "Available basic scripts ✨", message: "Choose one of them.", preferredStyle: .actionSheet)
        
        // Script: "Показати всі зображення"
        ac.addAction(UIAlertAction(title: "Show all images", style: .default, handler: { [weak self] _ in
            self?.script.text = """
            var imgs = document.images;
            for (var i = 0; i < imgs.length; i++) {
                console.log(imgs[i].src);
            } 
            """
        }))
        
        // Script: "Змінити фон на чорний"
        ac.addAction(UIAlertAction(title: "Change the background to black", style: .default, handler: { [weak self] _ in
            self?.script.text = """
            document.body.style.backgroundColor = "black";
            """
        }))
        
        // Script: "Змінити всі заголовки h1 на червоний"
        ac.addAction(UIAlertAction(title: "Change all h1 headings to red", style: .default, handler: { [weak self] _ in
            self?.script.text = """
            var headers = document.getElementsByTagName("h1");
            for (var i = 0; i < headers.length; i++) {
                headers[i].style.color = "red";
            }
            """
        }))
        
        // Script: "Виділити всі посилання жовтим"
        ac.addAction(UIAlertAction(title: "Highlight all links in yellow", style: .default, handler: { [weak self] _ in
            self?.script.text = """
            var links = document.getElementsByTagName("a");
            for (var i = 0; i < links.length; i++) {
                links[i].style.backgroundColor = "yellow";
            }
            """
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
                             
    
    // Це метод, який викликається, коли ти натискаєш кнопку "📜 My Scripts"
    @objc func showMyScripts() {
        let vc = MyScriptsViewController()
        
        // 🔹 Передаєш поточний список скриптів
            vc.scripts = scripts
            vc.onSelectScript = { [weak self] selectedScript in
                self?.script.text = selectedScript.code
            }
        
        // 🔹 Це замикання (closure), яке спрацьовує, коли в MyScriptsViewController користувач вибрав скрипт.
        // 🔹 Воно бере selectedScript.code і вставляє його у головне текстове поле (UITextView)
            vc.onScriptsChanged = { [weak self] updatedScripts in
                self?.scripts = updatedScripts
                self?.saveScripts() // правильна назва має бути saveScripts
            }
        
        // 🔹 Створюєш навігаційний контролер, який містить MyScriptsViewController.
        // 🔹 Це потрібно, щоби всередині нового екрану могли працювати кнопки вгорі (add, cancel) — без UINavigationController вони не відображались би.
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true)
    }
                             
    
    // Функція, що коригує текстове поле при появі клавіатури:
    @objc func adjustForKeyboard(notification: Notification) {
        // Витягуємо розмір клавіатури з userInfo
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        // Перетворюємо координати клавіатури у систему координат нашого View
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        // Якщо клавіатура ЗНИКАЄ – прибираємо відступи
        if notification.name == UIResponder.keyboardWillHideNotification {
            // Якщо клавіатура ховається — прибираємо відступи
            script.contentInset = .zero
        } else {
            // Інакше — додаємо відступ знизу на висоту клавіатури
            // мінус безпечна зона (наприклад, якщо є жестова панель на iPhone)
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        // Робимо те саме для смуги прокрутки
        script.scrollIndicatorInsets = script.contentInset
        
        // Прокручуємо текст так, щоб курсор був у полі зору
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    // Метод для отримання домену (host) з URL сторінки — використовується як ключ у UserDefaults
    func hostFromURL() -> String? {
        guard let url = URL(string: pageURL) else { return nil }
        return url.host
    }
    
    // Метод збереження тексту скрипта в UserDefaults за ключем домену сторінки
    func save() {
        if let host = hostFromURL() {
            let defaults = UserDefaults.standard
            defaults.set(script.text, forKey: host)
            print("📤 Script saved for \(host)")
        }
    }
    
    func loadScripts() {
        let defaults = UserDefaults.standard
        
        // дістаєш Data з UserDefaults
        if let savedOwnScripts = defaults.object(forKey: "scripts") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                // Декодуємо масив скриптів
                scripts = try jsonDecoder.decode([Script].self, from: savedOwnScripts)
            } catch {
                print("❌ Failed to load scripts: \(error.localizedDescription)")
            }
        }
    }
    
    func saveScripts() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(scripts) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "scripts")
        } else {
            print("❌ Failed to save scripts.")
        }
    }
    
    func stackedButtons() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4

        let scriptsButton = UIButton(type: .system)
        scriptsButton.setTitle("📜 My scripts", for: .normal)
        scriptsButton.addTarget(self, action: #selector(showMyScripts), for: .touchUpInside)

        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)

        stack.addArrangedSubview(scriptsButton)
        stack.addArrangedSubview(doneButton)

        return stack
    }
}
