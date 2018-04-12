//
//  CurrentRunVC.swift
//  treads
//
//  Created by Daniel Bonehill on 29/03/2018.
//  Copyright © 2018 Daniel Bonehill. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class CurrentRunVC: LocationVC {

    @IBOutlet weak var swipeBGImageView: UIImageView!
    @IBOutlet weak var sliderImageView: UIImageView!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var pauseBtn: UIButton!
    
    fileprivate var startLocation: CLLocation!
    fileprivate var lastLocation: CLLocation!
    fileprivate var timer = Timer()
    fileprivate var coordinateLocations = List<Location>()
    
    fileprivate var runDistance = 0.0
    fileprivate var runPace = 0
    fileprivate var runTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(endRunSwiped(sender:)))
        sliderImageView.addGestureRecognizer(swipeGesture)
        sliderImageView.isUserInteractionEnabled = true
        swipeGesture.delegate = self as? UIGestureRecognizerDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        manager?.delegate = self
        manager?.distanceFilter = 10
        startRun()
    }
    
    func startRun() {
        manager?.startUpdatingLocation()
        startTimer()
        pauseBtn.setImage(#imageLiteral(resourceName: "pauseButton"), for: .normal)
    }
    
    func endRun() {
        manager?.stopUpdatingLocation()
        Run.addRunToRealm(pace: runPace, distance: runDistance, duration: runTime, locations: coordinateLocations)
    }
    
    func pauseRun() {
        startLocation = nil
        lastLocation = nil
        timer.invalidate()
        manager?.stopUpdatingLocation()
        pauseBtn.setImage(#imageLiteral(resourceName: "resumeButton"), for: .normal)
    }
    
    func startTimer() {
        durationLbl.text = runTime.formatTimeDurationToString()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateRunTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateRunTime() {
        runTime += 1
        durationLbl.text = runTime.formatTimeDurationToString()
    }
    
    func calculatePace(time seconds: Int, miles: Double) -> String {
        runPace = Int(Double(seconds) / miles)
        return runPace.formatTimeDurationToString()
    }
    
    @IBAction func pauseBtnPressed(_ sender: Any) {
        if timer.isValid {
            pauseRun()
        } else {
            startRun()
        }
    }
    
    @objc func endRunSwiped(sender: UIPanGestureRecognizer) {
        let minAdjust: CGFloat = 80
        let maxAdjust: CGFloat = 128
        
        let startPoint = swipeBGImageView.center.x - minAdjust
        let endPoint = swipeBGImageView.center.x + maxAdjust
        
        if let sliderView = sender.view {
            if sender.state == UIGestureRecognizerState.began || sender.state == UIGestureRecognizerState.changed {
                let translation = sender.translation(in: self.view)
                
                if sliderView.center.x >= startPoint && sliderView.center.x <= endPoint {
                    sliderView.center.x = sliderView.center.x + translation.x
                } else if sliderView.center.x >= (endPoint) {
                    sliderView.center.x = endPoint
                    endRun()
                    dismiss(animated: true, completion: nil)
                } else {
                    sliderView.center.x = startPoint
                }
                sender.setTranslation(CGPoint.zero, in: self.view)
            } else if sender.state == UIGestureRecognizerState.ended {
                UIView.animate(withDuration: 0.1) {
                    sliderView.center.x = startPoint
                }
            }
        }
    }
}

extension CurrentRunVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationAuthStatus()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            runDistance += lastLocation.distance(from: location)
            let newLocation = Location(latitude: Double(lastLocation.coordinate.latitude), longitude: Double(lastLocation.coordinate.longitude))
            coordinateLocations.insert(newLocation, at: 0)
            distanceLbl.text = "\(runDistance.metersToMiles(places: 2))"
            if runTime > 0 && runDistance > 0 {
                paceLbl.text = calculatePace(time: runTime, miles: runDistance.metersToMiles(places: 2))
            }
        }
        lastLocation = locations.last
    }
}
