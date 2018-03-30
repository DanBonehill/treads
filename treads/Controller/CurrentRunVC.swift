//
//  CurrentRunVC.swift
//  treads
//
//  Created by Daniel Bonehill on 29/03/2018.
//  Copyright © 2018 Daniel Bonehill. All rights reserved.
//

import UIKit

class CurrentRunVC: LocationVC {

    @IBOutlet weak var swipeBGImageView: UIImageView!
    @IBOutlet weak var sliderImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(endRunSwiped(sender:)))
        sliderImageView.addGestureRecognizer(swipeGesture)
        sliderImageView.isUserInteractionEnabled = true
        swipeGesture.delegate = self as? UIGestureRecognizerDelegate
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
                    // End Run
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
