//
//  ViewController.swift
//  Project22
//
//  Created by mac on 08.07.2025.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet var circleView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var beaconLabel: UILabel!
    
    // MARK: - Properties
    var locationManager: CLLocationManager?     // Менеджер для роботи з локацією та iBeacon
    var firstDetection: Bool = true             // Показати alert лише один раз
    var currentBeaconUuid: UUID?                // Показати alert лише один раз
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLocationManager()
    }
    
    // challenge 3: налаштування UI
    private func setupUI() {
        view.backgroundColor = .gray
        beaconLabel.text = "Unknown"
        circleView.layer.cornerRadius = 128
        circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        circleView.backgroundColor = UIColor.white
    }
    
    // 1. Запит дозволу на локацію
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
    }
    
    
    // MARK: - Location Authorization
    // 2. Коли дозвіл надано – запускаємо сканування
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Коли користувач дозволив доступ — починаємо пошук
        if status == .authorizedAlways {
            // Перевіряємо, чи пристрій підтримує моніторинг Beacon-ів
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                // Перевіряємо, чи підтримується вимірювання відстані до Beacon
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    // MARK: - Scanning
    // 3. Початок сканування iBeacon
    private func startScanning() {
        addBeaconRegion(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5", major: 123, minor: 456, identifier: "Green Beacon 🟢")
        addBeaconRegion(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6", major: 123, minor: 456, identifier: "Blue Beacon 🔵")
        addBeaconRegion(uuidString: "92AB49BE-4127-42F4-B532-90fAF1E26491", major: 123, minor: 456, identifier: "Orange Beacon 🟠")
    }
    
    func addBeaconRegion(uuidString: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, identifier: String) {
        let uuid = UUID(uuidString: uuidString)!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: major, minor: minor, identifier: identifier)
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
    // MARK: - Beacon Detection
    // 4. Коли знайдено маяк — оновлюємо інтерфейс
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            // challenge 2
            // deal with one beacon at once
            if currentBeaconUuid == nil { currentBeaconUuid = region.proximityUUID }
            guard currentBeaconUuid == region.proximityUUID else { return }
            
            update(distance: beacon.proximity, name: region.identifier)
            
            // challenge 1
            showFirstDetection()
        }
        else {
            // challenge 2
            // deal with one beacon at once
            guard currentBeaconUuid == region.proximityUUID else { return }
            currentBeaconUuid = nil
            
            update(distance: .unknown, name: "Unknown")
        }
    }
    
    
    // MARK: - UI Updates
    // 5. Змінюємо колір і текст
    func update(distance: CLProximity, name: String) {
        UIView.animate(withDuration: 1) { [weak self] in
            // challenge 2
            self?.beaconLabel.text = "\(name)"
            
            switch distance {
            case .far:
                self?.view.backgroundColor = .blue
                self?.distanceLabel.text = "FAR"
                // challenge 3
                self?.circleView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
                self?.stopBlinkingCircle()
                
            case .near:
                self?.view.backgroundColor = .orange
                self?.distanceLabel.text = "NEAR"
                // challenge 3
                self?.circleView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self?.startBlinkingCircle()
                
            case .immediate:
                self?.view.backgroundColor = .red
                self?.distanceLabel.text = "RIGHT HERE"
                // challenge 3
                self?.circleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self?.startBlinkingCircle()
                
            case .unknown:
                fallthrough
                
            default:
                self?.view.backgroundColor = .gray
                self?.beaconLabel.text = "UNKNWON"
                self?.distanceLabel.text = "Unknown"
                // challenge 3
                self?.circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                self?.stopBlinkingCircle()
            }
        }
    }
    
    // MARK: - First Detection Alert
    // challenge 1
    func showFirstDetection() {
        if firstDetection {
            firstDetection = false
            let ac = UIAlertController(title: "Detected beacon!", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    
    // MARK: - Circle Animation
    func startBlinkingCircle() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.repeat, .autoreverse, .allowUserInteraction],
                       animations: { [weak self] in
            self?.circleView.alpha = 0.2
        }, completion: nil)
    }
    
    func stopBlinkingCircle() {
        circleView.layer.removeAllAnimations()
        circleView.alpha = 1.0
    }
    
}
