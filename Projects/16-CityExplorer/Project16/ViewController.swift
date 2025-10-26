//
//  ViewController.swift
//  Project16
//
//  Created by mac on 09.06.2025.
//

import UIKit
import MapKit
import Contacts

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "MAP"
        
        let london = Capital(title:  "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand vears ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        
        let myPlace = Place(coordinate: CLLocationCoordinate2D(latitude: 51.5083, longitude: -0.1384), title: "Fortnum & Mason", subtitle: "181 Piccadilly, St. James's", cityName: "London")
        
        
        mapView.addAnnotations([london, oslo, paris, rome, washington, myPlace])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "map"), style: .plain, target: self, action: #selector(selectedMap))
        
        mapView.mapType = .standard
        mapView.delegate = self
    }
    
    @objc func selectedMap() {
        let ac = UIAlertController(title: "Choose Map Type", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: { [weak self] _ in
            self?.mapView.mapType = .standard
        }))
        
        ac.addAction(UIAlertAction(title: "Muted Standard", style: .default, handler: { [weak self] _ in
            self?.mapView.mapType = .mutedStandard
        }))
        
        ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: { [weak self] _ in
            self?.mapView.mapType = .satellite
        }))
        
        ac.addAction(UIAlertAction(title: "Satellite Flyover", style: .default, handler: { [weak self] _ in
            self?.mapView.mapType = .satelliteFlyover
        }))
        
        ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: { [weak self] _ in
            self?.mapView.mapType = .hybrid
        }))
        
        ac.addAction(UIAlertAction(title: "Hybrid Flyover", style: .default, handler: { [weak self] _ in
            self?.mapView.mapType = .hybridFlyover
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    // Метод запитує у тебе вигляд для кожної анотації, яку MapKit хоче показати
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        
        // 1
        // Якщо annotation — не наша кастомна Capital, повертаємо nil (тобто не змінюємо стандартний вигляд)
        if let capital = annotation as? Capital {
            
            // 2
            // Identifier повторно використовує MKAnnotationView, щоб економити пам’ять
            let identifier = "Capital"
            
            // 3
            // Спроба отримати вже існуючий (перевикористаний) вигляд анотації з черги інакше - створюємо нову MKMarkerAnnotationView
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            // перезаписуємо стару анотацію свіжими даними
            annotationView.annotation = capital
            
            // Дозволяє показати спливаюче вікно при натисканні на маркер
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView.markerTintColor = .green
            
            return annotationView
            
        } else if let place = annotation as? Place {
            let identifier = "Place"
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            annotationView.annotation = place
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView.markerTintColor = .blue
            return annotationView
        }
        return nil
    }
    
    
    // Метод викликається, коли користувач натискає на кнопку в callout
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Перевіряєсо чи є кнопка i
        guard control == view.rightCalloutAccessoryView else { return }
        
        // Якщо кастомна анотація Capital
        if let capital = view.annotation as? Capital {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
                
                vc.urlType = .wikipedia
                vc.city = capital.title
                navigationController?.pushViewController(vc, animated: true)
            }
            
            // Якщо стандартна MKPlacemark
        } else if let place = view.annotation as? Place {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
                
                vc.city = place.title
                vc.urlType = .wikipedia
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

