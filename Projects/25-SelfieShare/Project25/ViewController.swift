//
//  ViewController.swift
//  Project25
//
//  Created by mac on 22.07.2025.
//

import UIKit
import MultipeerConnectivity
// це фреймворк, який дозволяє створити з'єднання між кількома пристроями без інтернету

class ViewController: UICollectionViewController {
    
    // MARK: - Properties
    var images = [UIImage]()
    
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    // Посилається на те, як поточний користувач відображається на інших пристроях
    var mcSession: MCSession?
    // Управляє всіма підключеннями, передачею даних
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    // Автоматично розрекламує сесію для з'єднання
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title =  "Selfie Share"
        
        setupNavigationBar() // Створення меню з кнопками
        setupMCSession()
    }
    
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .camera,
                target: self,
                action: #selector(importPicture)
            ),
            
            UIBarButtonItem(
                barButtonSystemItem: .compose,
                target: self,
                action: #selector(showMessage)
            )
        ]
        
        navigationItem.leftBarButtonItems =  [
            //  Кнопка, яка
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(showConnectionPrompt)
            ),
            //  Кнопка, яка показує список усіх підключених peer-ів
            UIBarButtonItem(
                title: "Peers",
                style: .plain,
                target: self,
                action: #selector(showConnectedPeers)
            )
        ]
    }
    
    private func setupMCSession() {
        // .required гарантує безпеку будь-яких переданих даних
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        // Повідомляє нас, коли щось трапляється
        mcSession?.delegate = self
    }
    
    
    // MARK: - UICollectionView DataSource (джерело даних)
    
    // Повертає кількість зображень у масиві images, щоб колекція знала, скільки комірок створити
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    // Комірка для кожного елемента:
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath)
        
        // В середині цієї комірки шукаємо UIImageView з тегом 1000
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]                //  номер елемента в секції
        }
        
        return cell
    }
    
    
    // MARK: - Image Import
    
    @objc  private func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    // MARK: - Messaging & Peers
    
    //  Створює текстове поле, перетворює текст у Data, викликає sendData(_:).
    @objc  private func showMessage() {
        let ac = UIAlertController(title: "Message:", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            guard let message = ac.textFields?[0].text else { return }
            let data = Data(message.utf8)
            self?.sendData(data)
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc  private func showConnectedPeers() {
        guard let session = mcSession else { return }
             let peersText = session.connectedPeers.map { $0.displayName }.joined(separator: "\n")
             let message = peersText.isEmpty ? "No peers connected" : peersText
             
             let ac = UIAlertController(title: "Connected peers", message: message, preferredStyle: .actionSheet)
             ac.addAction(UIAlertAction(title: "OK", style: .default))
             present(ac, animated: true)
    }
    
    
    // MARK: - Multipeer Actions
    @objc  private func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: hostSession))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    // Початок реклами сесії
    private func hostSession(action: UIAlertAction) {
        guard mcSession != nil else { return }
        
        mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "selfie-share")
        mcNearbyServiceAdvertiser.delegate = self
        mcNearbyServiceAdvertiser.startAdvertisingPeer()
        
        // розпочни шукати зʼєданання
        print("Hosting session...")
    }
    
    private func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: "selfie-share", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
        
        print("Searching sessions...")
    }
    
    func sendData(_ data: Data) {
        // Фрагмент коду, який надсилає дані зображення ближнім
        guard let session = mcSession, !session.connectedPeers.isEmpty else { return }
        
        do {
            // .reliable — забезпечує гарантовану доставку
            try  session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    private func presentAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        images.insert(image, at: 0)
        collectionView.reloadData()
        
        // Поділитися зображенням, яке ми вибрали для сесії
        if let imageData  = image.pngData() {
            sendData(imageData)
        }
    }
}

// MARK: - MCSessionDelegate

extension ViewController: MCSessionDelegate {
    
    // Отримання даних. Тут перевіряємо, чи з Data вийде створити зображенн
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Отримуєм дані у головному потоці, оскільки ми знаходимось в інтерфейсі
        DispatchQueue.main.async { [ weak self ] in
            guard let self = self else { return }
            if let image = UIImage(data: data) {
                // Це зображення
                self.images.insert(image, at: 0)
                self.collectionView.reloadData()
            } else {
                // перевіряє, чи це текст, і показує алерт
                let message = String(decoding: data, as: UTF8.self)
                self.presentAlert(title: "Message from \(peerID.displayName)", message: message)
            }
        }
    }
    
    
    //  Реакція на відключення peer-ів
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Peer status changed: \(peerID.displayName), state: \(state.rawValue)")
        
        if state  == .notConnected {
            DispatchQueue.main.async { [weak self] in
                // показує повідомлення при відключенні peer
                self?.presentAlert(title: "Disconnected", message: "\(peerID.displayName) has disconnected.")
            }
        }
        
//        switch state {
//        case .connected:
//            print("Conected: \(peerID.displayName)")
//            
//        case .connecting:
//            print("Conecting: \(peerID.displayName)")
//            
//        case .notConnected:
//            print("Not Conected: \(peerID.displayName)")
//        
//        // Для невідомих майбутніх випадків, які не належать до жодного з цих
//        @unknown default:
//            print("Unknown state received: \(peerID.displayName)")
//        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension ViewController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Invitation Received"

        let ac = UIAlertController(title: appName, message: "'\(peerID.displayName)' wants to connect.", preferredStyle: .alert)
        let declineAction = UIAlertAction(title: "Decline", style: .cancel) { [weak self] _ in invitationHandler(false, self?.mcSession) }
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { [weak self] _ in invitationHandler(true, self?.mcSession) }
        
        ac.addAction(declineAction)
        ac.addAction(acceptAction)
        
        present(ac, animated: true)
    }
}


// MARK: - MCSessionDelegate
extension ViewController: MCBrowserViewControllerDelegate {
    
    // Багатокористувацького браузер успішно завершується
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) { dismiss(animated: true) }
    
    // Користувач скасовує
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) { dismiss(animated: true) }
}
