//
//  YawAlgorithm.swift
//  GoogleMapAPINavigation
//
//  Created by 李晉杰 on 2022/12/6.
//

import Foundation
class YawAlgorithm {
    var yawState:Bool = false
    func YawAlgorithm1(_ latFromInertia:Double,_ lngFromInertia:Double,_ latFromSnap:Double,_ lngFromSnap:Double)->Bool {
       let distance = GoogleMapVM().getDistance(lat1: latFromInertia, lng1: lngFromInertia, lat2: latFromSnap, lng2: lngFromSnap)
        if distance >= 30 {
            yawState = true
        }
        return yawState
    }
}
