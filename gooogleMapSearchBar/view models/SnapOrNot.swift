//
//  File.swift
//  GoogleMapAPINavigation
//
//  Created by 李晉杰 on 2022/12/9.
//

import Foundation
class positionBox {
    enum positionSwitch {
        case gps
        case snap
    }
    var snapLat:Double = 0
    var snapLng:Double = 0
    var switchType = positionSwitch.gps
    func switchBox(_ lat:Double, _ lng:Double) -> (Double,Double) {
        var position:(Double,Double) = (0,0)
        switch switchType {
        case.gps:
            position = gpsPosition(lat,lng)
        case.snap:
            snapPosition(lat,lng)
            position.0 = snapLat //目前只會拿到０
            position.1 = snapLng
        }
        return position
    }
    func gpsPosition(_ lat:Double, _ lng:Double) -> (Double,Double) {
        return (lat,lng)
    }
    func snapPosition(_ lat:Double, _ lng:Double)  {
        GoogleMapM<SnapToRoadsData>().snapToRoadsParser(myLat: lat, myLng: lng )  {
            [weak self] snapToRoadsDataResult in
            self?.snapLat = snapToRoadsDataResult.latitude
            self?.snapLng = snapToRoadsDataResult.longitude
            //無法回傳
        }
    }
}
