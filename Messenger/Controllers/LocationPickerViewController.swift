//
//  LocationPickerViewController.swift
//  Messenger
//
//  Created by MRK on 17.06.2024.
//

import UIKit
import CoreLocation
import MapKit

class LocationPickerViewController: UIViewController, CLLocationManagerDelegate {

    public var copmletion: ((CLLocationCoordinate2D) -> Void)?
    private var coordinates: CLLocationCoordinate2D?
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pick Location"
        view.backgroundColor = .systemBackground
        
        // send butonu
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(sendButtonTapped))
        view.addSubview(map)
        map.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapMap(_:)))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        map.addGestureRecognizer(gesture)
    }
    
    @objc func sendButtonTapped() {
        guard let coordinates = coordinates else {
            return
        }
        copmletion?(coordinates)
        
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        
        // tek bir pin oluşturmak için
        // ikinici pin olduğunda diğer pin siliniyor
        // 22_43
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        
        // konuma pin bırakma işlmei
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    
}
