//
//  Extensions.swift
//  treads
//
//  Created by Daniel Bonehill on 30/03/2018.
//  Copyright © 2018 Daniel Bonehill. All rights reserved.
//

import Foundation

extension Double {
    func metersToMiles(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return ((self / 1609.34) * divisor).rounded() / divisor
    }
}
