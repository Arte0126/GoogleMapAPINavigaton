//
//  GoogleMapV.swift
//  gooogleMapSearchBar
//
//  Created by 李晉杰 on 2022/11/16.
//

import UIKit
import GoogleMaps
import SwiftUI
class GoogleMapV: UIView, CLLocationManagerDelegate {
    var mapViewForUI: GMSMapView!
    var mapLocationManager = CLLocationManager() //我的位置（畫面）
    let searchController = UISearchController()
    func mapView(mapView:UIView) {
        if CLLocationManager.headingAvailable() {
            mapLocationManager.headingFilter = 5
            mapLocationManager.startUpdatingHeading()
        }
        let camera = GMSCameraPosition(latitude: 22.651061, longitude: 120.312894, zoom: 13)
        mapViewForUI = GMSMapView.map(withFrame: mapView.bounds, camera: camera)
//        mapViewForUI.delegate = self
        mapViewForUI.isMyLocationEnabled = true
        mapView.addSubview(mapViewForUI)
        mapLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        mapLocationManager.delegate = self
        mapLocationManager.requestWhenInUseAuthorization()
        mapLocationManager.startUpdatingLocation()
//        let searchResultList =
//        GoogleMapVM().textSearchDataGet(keyWord: "高中", lat: 22.651061, lng: 120.312894)
//        GoogleMapVM().mapRouteDataGet(myLat: 22.651061, myLng: 120.312894, annLat: 22.755039, annLng: 120.500603)
//          GoogleMapVM().NavigationDataGet(myLat: 22.651061, myLng: 120.312894, annLat: 22.755039, annLng: 120.500603)
//        GoogleMapVM().directionDataGet(myLat: 22.651061, myLng: 120.312894, annLat: 22.755039, annLng: 120.500603)
        
//        GoogleMapVM().snapToRoadsDataGet(myLat: 22.651061, myLng: 120.312894)
    }
    func searchbarView() {
        
       
    }
    


}
