//
//  ViewController.swift
//  Project4
//
//  Created by mac on 22.01.2025.
//

/*
import UIKit
import WebKit // забеспечує інструменти для веб-контенту
 
    /// Description for Challenge
    ///
 /*
  For more of a challenge, try changing the initial view controller to a table view like in project 1, where users can choose their website from a list rather than just having the first in the array loaded up front.
  */

class ViewController: UITableViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["apple.com", "hackingwithswift.com", "spotify.com", "discord.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Заголовок та Large title
        title = "Select a Website"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .inline

        // ------------------------------------------
        // Налаштування WebView **під таблицею**
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        webView.isHidden = true
        view.insertSubview(webView, belowSubview: tableView) // <- ключовий рядок
        // ------------------------------------------

        // Прогрес-бар у toolbar
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
        
        toolbarItems = [progressButton, spacer, refresh, backButton]
        
        // ------------------------------------------
        // toolbar видно і фон непрозорий
        navigationController?.isToolbarHidden = false // <- ключовий рядок
        navigationController?.toolbar.barTintColor = .systemBackground // <- ключовий рядок
        navigationController?.toolbar.isTranslucent = false // <- ключовий рядок
        // ------------------------------------------
        
        // Спостерігач прогресу
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new, context: nil)
    }
    
    // UITableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { websites.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }
    
    // Коли користувач вибирає сайт, відкривається відповідна сторінка
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let website = websites[indexPath.row]
        guard let url = URL(string: "https://" + website) else { return }
        
        webView.load(URLRequest(url: url))
        webView.isHidden = false
    }
    
    // Встановлює заголовок сторінки як назву в Navigation Bar
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { title = webView.title }
    
    // Повернення назад
    @objc func goBack() {
        if !webView.isHidden && webView.canGoBack {
            webView.goBack()
        } else {
            webView.isHidden = true
            tableView.isHidden = false
            title = "Select a Website"
        }
    }
    
    // Оновлення прогрес-бару
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    // Обмеження доступу до сайтів
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            if !websites.contains(where: { host.contains($0) }) {
                let alert = UIAlertController(title: nil, message: "Your access to this web page is restricted!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
}
 */

  
 import UIKit
 import WebKit // забеспечує інструменти для веб-контенту

 class ViewController: UITableViewController, WKNavigationDelegate {
     var webView: WKWebView! // оголошується для відображення вебконтенту
     var progressView: UIProgressView!
     
     
     var websites = ["apple.com", "hackingwithswift.com", "spotify.com", "discord.com"]
     
     override func loadView() {
         webView = WKWebView()
         webView.navigationDelegate = self // отримуємо події від webView
         view = webView
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         // додавання кнопки в Navigation Bar
         navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
         
         title = "Web - sites"
         
      
         // Створюється гнучкий простір для розміщення кнопопок
         let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
         
         let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
         
         let forwardButton = UIBarButtonItem(title: "Forward", style: .plain, target: self, action: #selector(goForward))
         
         // Створюється системна кнопка з іконкою "Оновити"
         let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
         
         // ініціалізація прогрес-бару,який буде відображати процес завантаження сторінки
         progressView = UIProgressView(progressViewStyle: .default)
         progressView.sizeToFit() // підлаштовується під простір
         let progressButton = UIBarButtonItem(customView: progressView) // сама кнопка(прогрес-бар)
         
         toolbarItems = [progressButton, spacer, refresh, backButton, forwardButton]
         navigationController?.isToolbarHidden = false // прихована нижня панель інструментів
         navigationController?.navigationBar.isTranslucent = false // визначає чи буде панель навігації прозорою
         
         // Додається спостерігач за властивістю estimatedProgress(процес завантаження) у WKWebView
         webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress),options: .new, context: nil)
         
         // Завантаження першого сайту із масиву websites
         let url = URL(string: "https://" + websites[0])!
         webView.load(URLRequest(url: url))
         webView.allowsBackForwardNavigationGestures = true // дозволяє користувачам гортати вперед/назад.
         
         
     }
     
     @objc func goBack() {
         if webView.canGoBack {
             webView.goBack()
         }
     }
     
     @objc func goForward() {
         if webView.canGoForward {
             webView.goForward()
         }
     }
     
     // Відкривається спливаюче меню для вибору вебсайту
     @objc func openTapped () {
         let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
         
         ac.addAction(UIAlertAction(title: "google.com", style: .default, handler: openPage))
         
         // Для кожного сайту додається кнопка:
         for website in websites {
             ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
         }
       
         // Кнопка "Cancel" закриває меню
         ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
         
         ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
         present(ac, animated: true)
     }
     
     // Завантажує вибраний сайт у WKWebView
     func openPage(action: UIAlertAction) {
         guard let actionTitle = action.title else { return }
         guard let url = URL(string: "https://" + actionTitle) else { return }
         
         webView.load(URLRequest(url: url))
             
     }
     
     // Встановлює заголовок сторінки як назву в Navigation Bar
     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
         title = webView.title
     }
     
     // Оновлюється прогрес коли estimatedPgogress змінюється
 override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         if keyPath == "estimatedProgress" {
             progressView.progress = Float(webView.estimatedProgress) // Прогрес-бар оновлюється
         }
     }
     
     // Метод делегата для обмеження доступу
     func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
         let url = navigationAction.request.url
         
         // Перевіряємо чи є сайт у списку
         if let host = url?.host {
             
             // Перевіряємо, чи дозволений сайт з масиву websites
                if !websites.contains(where: { host.contains($0) }) {
                    // Якщо сайт не у списку дозволених, сповіщаємо про блокування
                    let alert = UIAlertController(title: nil, message: "Your access to this web page is restricted!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true)
                    
                    // Блокуємо доступ до сайту
                    decisionHandler(.cancel)
                    return
                }
            }
         // Якщо сайт в списку дозволених, дозволяємо доступ
         decisionHandler(.allow)
     }
 }
