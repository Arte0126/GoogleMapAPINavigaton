//
//  InertiaPoint.swift
//  GoogleMapAPINavigation
//
//  Created by 李晉杰 on 2022/11/24.
//
import Foundation
import GoogleMaps
class InertiaPoint {
//    var polylinePointDistanceVal:Double = 0 //polyline每兩點距離
//    var polylinePointDistanceList:[Double] = [] //polyline所有兩點距離陣列
//    var polylinePointAngleList:[Double] = [] //polyline所有兩點方向角陣列
//    var polylinePointDistanceAddList:[Double] = [] // 將polyline每點的距離疊加並裝進陣列
//    var polylinePointLatList:[Double] = [] // polyline所有經度組成陣列
//    var polylinePointLngList:[Double] = []// polyline所有緯度組成陣列
//    var polylineSmallPointLatList:[Double] = [] //polyline所有座標切成個多點後取出所有經度組成陣列
//    var polylineSmallPointLngList:[Double] = []//polyline所有座標切成個多點後取出所有緯度組成陣列
    func getPolylineValForDistance(polylinePoint:[CLLocationCoordinate2D]) -> Double {
        var polylinePointDistanceVal:Double = 0
        for i in 0...polylinePoint.count - 2 {//減２是因為最後一點沒有距離(算出polyline每點的距離與角度並裝進陣列)
            polylinePointDistanceVal = GoogleMapVM().getDistance(lat1: polylinePoint[i].latitude, lng1: polylinePoint[i].longitude, lat2: polylinePoint[i+1].latitude, lng2: polylinePoint[i+1].longitude)
        }
        return polylinePointDistanceVal
    }
    func getPolylineListForDistance(polylinePoint:[CLLocationCoordinate2D]) -> [Double] {
        var polylinePointDistanceList:[Double] = []
        for i in 0...polylinePoint.count - 2 {//減２是因為最後一點沒有距離(算出polyline每點的距離與角度並裝進陣列)
            polylinePointDistanceList.append(GoogleMapVM().getDistance(lat1: polylinePoint[i].latitude, lng1: polylinePoint[i].longitude, lat2: polylinePoint[i+1].latitude, lng2: polylinePoint[i+1].longitude))
        }
        return polylinePointDistanceList
    }
    func getpolylineListForAngle(polylinePoint:[CLLocationCoordinate2D]) -> [Double] {
        var polylinePointAngleList:[Double] = []
        for i in 0...polylinePoint.count - 2 {//減２是因為最後一點沒有距離(算出polyline每點的距離與角度並裝進陣列)
            polylinePointAngleList.append(GoogleMapVM().getPointsAngle(lat1: polylinePoint[i].latitude, lng1: polylinePoint[i].longitude, lat2: polylinePoint[i+1].latitude, lng2: polylinePoint[i+1].longitude))
        }
        return polylinePointAngleList
    }
    func getPpolylineListForDistanceAdd(polylinePoint:[CLLocationCoordinate2D]) -> [Double] {
        let polylinePointDistanceList = getPolylineListForDistance(polylinePoint:polylinePoint)
        var polylinePointDistanceAddList:[Double] = []
        for i in 0...polylinePointDistanceList.count-1 { //將polyline每點的距離疊加並裝進陣列
            var distanceSum:Double = 0
            for j in (0...i).reversed()  {
                if j >= 0 {
                    distanceSum = distanceSum + polylinePointDistanceList[j]
                }
            }
            polylinePointDistanceAddList.append(distanceSum)
        }
        return polylinePointDistanceAddList
    }
    func getPolylineListForPoint(polylinePoint:[CLLocationCoordinate2D]) -> ([Double],[Double]) {
        var polylinePointLatList:[Double] = []
        var polylinePointLngList:[Double] = []
        for i in 0...polylinePoint.count - 1 {//取出polyline經緯度
            polylinePointLatList.append(polylinePoint[i].latitude)
            polylinePointLngList.append(polylinePoint[i].longitude)
        }
        let polylinePointObj = (polylinePointLatList,polylinePointLngList)
        return polylinePointObj
    }
    func getPolylineListForSmallPoint(polylinePoint:[CLLocationCoordinate2D]) -> ([Double],[Double]) {
       let polylinePointDistanceList = getPolylineListForDistance(polylinePoint:polylinePoint)
       let polylinePointAngleList = getpolylineListForAngle(polylinePoint:polylinePoint)
        let polylinePointLatList = getPolylineListForPoint(polylinePoint:polylinePoint).0
        let polylinePointLngList = getPolylineListForPoint(polylinePoint:polylinePoint).1
        var polylineSmallPointLatList:[Double] = []
        var polylineSmallPointLngList:[Double] = []
        for i in 0...polylinePointDistanceList.count - 1 { //將polyline每點再切成小點(每一公尺切一點)
            for j in 0...Int(polylinePointDistanceList[i]) {
                let smallPoint =
                GoogleMapVM().getNewPosition(lastAngle:polylinePointAngleList[i] , mylat:  polylinePointLatList[i], mylng:  polylinePointLngList[i], Distnace:Double(1*j))
                polylineSmallPointLatList.append(smallPoint.0)
                polylineSmallPointLngList.append(smallPoint.1)
            }
        }
        let polylineSmallPointObj = (polylineSmallPointLatList,polylineSmallPointLngList)
        print(polylineSmallPointObj)
        return polylineSmallPointObj
    }
}

