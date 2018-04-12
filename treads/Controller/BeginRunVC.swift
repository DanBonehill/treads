//
//  BeginRunVC.swift
//  treads
//
//  Created by Daniel Bonehill on 29/03/2018.
//  Copyright © 2018 Daniel Bonehill. All rights reserved.
//

import UIKit
import MapKit

class BeginRunVC: LocationVC {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lastRunCloseBtn: UIButton!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var lastRunBGView: UIView!
    @IBOutlet weak var lastRunStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        manager?.delegate = self
        manager?.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupMapView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        manager?.stopUpdatingLocation()
    }
    
    func setupMapView() {
        if let overlay = addLastRunToMap() {
            if mapView.overlays.count > 0 {
                mapView.removeOverlays(mapView.overlays)
            }
            mapView.add(overlay)
            lastRunStack.isHidden = false
            lastRunBGView.isHidden = false
            lastRunCloseBtn.isHidden = false
        } else {
            lastRunStack.isHidden = true
            lastRunBGView.isHidden = true
            lastRunCloseBtn.isHidden = true
        }
    }
    
    func addLastRunToMap() -> MKPolyline? {
        guard let lastRun = Run.getAllRuns()?.first else { return nil }
        paceLbl.text = lastRun.pace.formatTimeDurationToString()
        distanceLbl.text = "\(lastRun.distance.metersToMiles(places: 2)) mi"
        durationLbl.text = lastRun.duration.formatTimeDurationToString()
        
        var coordinates = [CLLocationCoordinate2D]()
        for location in lastRun.locations {
            coordinates.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        
        return MKPolyline(coordinates: coordinates, count: lastRun.locations.count)
    }
    
    @IBAction func lastRunCloseBtnPressed(_ sender: Any) {
        lastRunStack.isHidden = true
        lastRunBGView.isHidden = true
        lastRunCloseBtn.isHidden = true
    }
    
    @IBAction func locationCenterBtnPressed(_ sender: Any) {
        
    }
}

extension BeginRunVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationAuthStatus()
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        renderer.lineWidth = 4
        return renderer
    }
}
