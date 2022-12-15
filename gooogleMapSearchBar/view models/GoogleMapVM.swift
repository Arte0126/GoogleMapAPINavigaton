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
    func radian(degree:Double) -> Double {
        return degree * Double.pi/180.0
    }
    func angle(radian:Double) -> Double {
        return radian * 180/Double.pi
    }
    func cameraPositionToBottom(_ angleVal:Double,_ lat:Double,_ lng:Double) -> (Double,Double){
        let distance:Double = 0.05
        let earthArc:Double = 111.199
        let bearing:Double = self.radian(degree: angleVal)
        let navStepsLatValForCamera = lat + (distance * cos(bearing)) / earthArc
        let navStepsLngValForCamera = lng + (distance * sin(bearing)) / (earthArc * cos(radian(degree:lat)));
        let myCameraPosition = (lat:navStepsLatValForCamera,lng:navStepsLngValForCamera)
        return myCameraPosition
    }
    func getDistance(lat1:Double,lng1:Double,lat2:Double,lng2:Double) -> Double {//兩座標點直線距離
        let earthRaduis:Double = 6378137.0
        let radLat1:Double = self.radian(degree: lat1)
        let radLat2:Double = self.radian(degree: lat2)
        let radLng1:Double = self.radian(degree: lng1)
        let radLng2:Double = self.radian(degree: lng2)
        let radLat:Double = radLat1 - radLat2
        let radLng:Double = radLng1 - radLng2
        let result:Double = 2 * asin(sqrt(pow(sin(radLat/2), 2) + cos(radLat1) * cos(radLat2) * pow(sin(radLng/2), 2))) * earthRaduis
//        result = result * earthRaduis
//        s = String(format: "%.2f", s) //直線距離
        return result //公尺
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
        let bearing:Double = self.radian(degree: lastAngle)
        var newMylat = mylat + (distance * cos(bearing)) / EARTH_ARC
        var newMylng = mylng + (distance * sin(bearing)) / (EARTH_ARC * cos(radian(degree:mylat)));
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
//    func mapRouteDataGet(myLat: Double,myLng: Double,annLat:Double ,annLng:Double) {
//        GoogleMapM<MapRouteData>().mapRouteDataParser(myLat: myLat,myLng: myLng,annLat:annLat ,annLng:annLng) {
//            [weak self]  mapRouteDataResult in
//            for i in 0...mapRouteDataResult.points.count-1 {
//                self?.path = GMSPath(fromEncodedPath:mapRouteDataResult.points[i])!
//                self?.polyline = GMSPolyline(path: self?.path)
//                self?.polyline.strokeWidth = enumClass().WidthState(value: self!.polylineWidth)
//                self?.polyline.strokeColor = .red
//                self?.polyline.map = self?.mapViewForUI
//                self?.polylinePoint = decodePolyline(mapRouteDataResult.polylinePoint)!
//                let pathForCamera = GMSPath(fromEncodedPath: mapRouteDataResult.polylinePoint)!
//                let bounds = GMSCoordinateBounds(path:pathForCamera)
//                let camera = GMSCameraUpdate.fit(bounds, withPadding: 140)
//                self?.mapViewForUI.animate(with: camera)
//            }
//        }
//    }
//    func gpsInteriaDataGet(myLat: Double,myLng: Double,annLat:Double ,annLng:Double) {
//        GoogleMapM<MapRouteData>().mapRouteDataParser(myLat: myLat,myLng: myLng,annLat:annLat ,annLng:annLng) {
//            [weak self]  mapRouteDataResult in
//            for i in 0...mapRouteDataResult.points.count-1 {
//                self?.path = GMSPath(fromEncodedPath:mapRouteDataResult.points[i])!
//                self?.polyline = GMSPolyline(path: self?.path)
//                self?.polylinePoint = decodePolyline(mapRouteDataResult.polylinePoint)!
//            }
//            self?.navPolyLineProcess()
//        }
//
//    }
//    func NavigationDataGet(myLat: Double,myLng: Double,annLat:Double ,annLng:Double) {
//        GoogleMapM<NavigationData>().navigationParser(myLat: myLat,myLng: myLng,annLat:annLat ,annLng:annLng) {
//            [weak self]  navigationDataResult in
//            for i in 0...navigationDataResult.navStepsLatList.count-1 {
//                self?.navManeuverList = navigationDataResult.navManeuverList
//                self?.navStepsRemindList = navigationDataResult.navStepsRemindList
//                self?.navStepsTittleList = navigationDataResult.navStepsTittleList
//                self?.navStepsLatList = navigationDataResult.navStepsLatList
//                self?.navStepsLngList = navigationDataResult.navStepsLngList
//            }
//            self?.navPolyLineProcess()
//        }
//
//    }
}

