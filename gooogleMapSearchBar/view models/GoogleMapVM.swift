//
//  GoogleMapVM.swift
//  gooogleMapSearchBar
//
//  Created by 李晉杰 on 2022/11/16.
//
import GoogleMaps
import Polyline

import Foundation
class GoogleMapVM {
    var navStepsRemindList:[String] = []
    var navStepsTittleList:[String] = []
    var navManeuverList:[String] = []
    var navStepsLatList:[Double] = []
    var navStepsLngList:[Double] = []
    func radian(d:Double) -> Double {
        return d * Double.pi/180.0
    }
    func angle(r:Double) -> Double {
        return r * 180/Double.pi
    }
    func cameraPositionToBottom(_ angleVal:Double,_ lat:Double,_ lng:Double) -> (Double,Double){
        let distance:Double = 0.05
        let EARTH_ARC:Double = 111.199
        let bearing:Double = self.radian(d: angleVal)
        let navStepsLatValForCamera = lat + (distance * cos(bearing)) / EARTH_ARC
        let navStepsLngValForCamera = lng + (distance * sin(bearing)) / (EARTH_ARC * cos(radian(d:lat)));
        let myCameraPosition = (lat:navStepsLatValForCamera,lng:navStepsLngValForCamera)
        return myCameraPosition
    }
    func getDistance(lat1:Double,lng1:Double,lat2:Double,lng2:Double) -> Double {//兩座標點直線距離
        let EARTH_RADIUS:Double = 6378137.0
        let radLat1:Double = self.radian(d: lat1)
        let radLat2:Double = self.radian(d: lat2)
        let radLng1:Double = self.radian(d: lng1)
        let radLng2:Double = self.radian(d: lng2)
        let a:Double = radLat1 - radLat2
        let b:Double = radLng1 - radLng2
        var s:Double = 2 * asin(sqrt(pow(sin(a/2), 2) + cos(radLat1) * cos(radLat2) * pow(sin(b/2), 2)))
        s = s * EARTH_RADIUS
//        s = String(format: "%.2f", s) //直線距離
        return s //公尺
    }
    func getPointsAngle(lat1:Double,lng1:Double,lat2:Double,lng2:Double) -> Double {//兩點算方向角
        let degress:Double = Double.pi / 180.0;
        let phi1:Double = lat1 * degress;
        let phi2:Double = lat2 * degress;
        let lam1:Double = lng1 * degress;
        let lam2:Double = lng2 * degress;
        let x:Double = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(lam2 - lam1);
        let y:Double = sin(lam2 - lam1) * cos(phi2);
        var bearing:Double = (((atan2(y, x) * 180) / Double.pi) + 360)
        bearing = bearing.truncatingRemainder(dividingBy: 360)
        if (bearing < 0) {
            bearing = bearing + 360;
        }
        return bearing
    }
    func getNewPosition(lastAngle:Double,mylat:Double,mylng:Double,Distnace:Double) -> (Double,Double){//位移座標
        let distance:Double = Distnace/1000 //distance 單位為公里
        let EARTH_ARC:Double = 111.199
        let bearing:Double = self.radian(d: lastAngle)
        var newMylat = mylat + (distance * cos(bearing)) / EARTH_ARC
        var newMylng = mylng + (distance * sin(bearing)) / (EARTH_ARC * cos(radian(d:mylat)));
        var newMyPosition = (newMylat,newMylng)
        return newMyPosition
    }
//
//    func directionDataGet(myLat: Double,myLng: Double,annLat:Double ,annLng:Double) {
//        GoogleMapM<MapRouteData>().directionDataParser(myLat: myLat,myLng: myLng,annLat:annLat ,annLng:annLng) {
//            [weak self]  mapRouteDataResult in
//            for i in 0...mapRouteDataResult.points.count-1 {
//                self?.path = GMSPath(fromEncodedPath:mapRouteDataResult.points[i])!
//                self?.polyline = GMSPolyline(path: self?.path)
//                self?.polyline.strokeWidth = 20
//                self?.polyline.strokeColor = .red
//                self?.routerPolyline = decodePolyline(mapRouteDataResult.points[i])!
//                let pathForCamera = GMSPath(fromEncodedPath: mapRouteDataResult.polylinePoint)!
//                let bounds = GMSCoordinateBounds(path:pathForCamera)
//                let camera = GMSCameraUpdate.fit(bounds, withPadding: 140)
//            }
//        }
//    }
}

