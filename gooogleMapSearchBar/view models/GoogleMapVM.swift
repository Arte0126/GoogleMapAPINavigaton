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
    var searchResultList:[String] = []
    var searchResultLatList:[Double] = []
    var searchResultLngList:[Double] = []
    
    var path = GMSPath()
    var polyline = GMSPolyline()
    var routerPolyline:[CLLocationCoordinate2D] = []//目的地路徑（畫面）
    
    var navStepsRemindList:[String] = []
    var navStepsTittleList:[String] = []
    var navManeuverList:[String] = []
    var navStepsLatList:[Double] = []
    var navStepsLngList:[Double] = []
    
    
    
    var snapLat:Double = 0
    var snapLng:Double = 0
//    var polylinePoint:[CLLocationCoordinate2D] = []
    
//    let serialQueue: DispatchQueue = DispatchQueue(label: "serialQueue")
    func textSearchDataGet(keyWord: String, lat: Double, lng: Double) -> ([String]) {
        GoogleMapM<textSearchData>().textSearchDataParser(keyWord: keyWord, lat: lat, lng: lng){
            [weak self] textSearchResult in
//          print(textSearchData)
//            self?.serialQueue.sync {
//          for i in 0...textSearchData.searchResultList.count-1{
            self?.searchResultList = textSearchResult.searchResultList
            self?.searchResultLatList = textSearchResult.searchResultLatList
            self?.searchResultLngList = textSearchResult.searchResultLngList
//            print(self?.searchResultList ?? [])
//          }
//          print(self?.searchResultList ?? [])
         
                
//            }
        }
        return searchResultList
    }
    func mapRouteDataGet(myLat: Double,myLng: Double,annLat:Double ,annLng:Double) {
        GoogleMapM<MapRouteData>().mapRouteDataParser(myLat: myLat,myLng: myLng,annLat:annLat ,annLng:annLng) {
            [weak self]  mapRouteDataResult in
            for i in 0...mapRouteDataResult.points.count-1 {
                self?.path = GMSPath(fromEncodedPath:mapRouteDataResult.points[i])!
                self?.polyline = GMSPolyline(path: self?.path)
                self?.polyline.strokeWidth = 20
                self?.polyline.strokeColor = .red
//                self?.polyline.map = self?.mapViewForUI
                self?.routerPolyline = decodePolyline(mapRouteDataResult.points[i])!
//                self?.polylinePoint = decodePolyline(mapRouteDataResult.polylinePoint)!
                let pathForCamera = GMSPath(fromEncodedPath: mapRouteDataResult.polylinePoint)!
                let bounds = GMSCoordinateBounds(path:pathForCamera)
                let camera = GMSCameraUpdate.fit(bounds, withPadding: 140)
//                self?.mapViewForUI.animate(with: camera)
//                print(self?.path)
//                print(camera)
            }
        }
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
    
    
    
    
    func NavigationDataGet(myLat: Double,myLng: Double,annLat:Double ,annLng:Double) {
        GoogleMapM<NavigationData>().NavigationParser(myLat: myLat,myLng: myLng,annLat:annLat ,annLng:annLng) {
            [weak self]  navigationDataResult in
            for i in 0...navigationDataResult.navStepsLatList.count-1 {
                self?.navManeuverList = navigationDataResult.navManeuverList
                self?.navStepsRemindList = navigationDataResult.navStepsRemindList
                self?.navStepsTittleList = navigationDataResult.navStepsTittleList
                self?.navStepsLatList = navigationDataResult.navStepsLatList
                self?.navStepsLngList = navigationDataResult.navStepsLngList
            }
//            print(navigationDataResult.navManeuverList)
//            print(navigationDataResult.navStepsRemindList)
//            print(navigationDataResult.navStepsTittleList)

        }
    }
    func snapToRoadsDataGet(myLat:Double,myLng:Double) {
        GoogleMapM<snapToRoadsData>().snapToRoadsParser(myLat: myLat, myLng: myLng) { [weak self] snapToRoadsDataResult in
            self?.snapLat = snapToRoadsDataResult.latitude
            self?.snapLng = snapToRoadsDataResult.longitude
        }
    }
}

