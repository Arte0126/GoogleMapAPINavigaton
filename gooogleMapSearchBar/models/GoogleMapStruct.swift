//
//  googleMapStructM.swift
//  gooogleMapSearchBar
//
//  Created by 李晉杰 on 2022/11/16.
//
import Polyline
import Foundation
struct TextSearchData:Codable{
    let searchResultList:[String]
    let searchResultLatList:[Double]
    let searchResultLngList:[Double]
    init(searchResultList: [String], searchResultLatList:[Double], searchResultLngList: [Double]){
        self.searchResultList = searchResultList
        self.searchResultLatList = searchResultLatList
        self.searchResultLngList = searchResultLngList
    }
}
struct MapRouteData:Codable{
    let points:[String]
    let polylinePoint:String
    init(points:[String],polylinePoint:String){
        self.points = points
        self.polylinePoint = polylinePoint
    }
}
struct NavigationData:Codable{
    var navStepsRemindList:[String]
    var navStepsTittleList:[String]
    var navManeuverList:[String]
    var navStepsLatList:[Double]
    var navStepsLngList:[Double]
    init(navStepsRemindList:[String],navStepsTittleList:[String],navManeuverList:[String],navStepsLatList:[Double],navStepsLngList:[Double]){
        self.navStepsRemindList = navStepsRemindList
        self.navStepsTittleList = navStepsTittleList
        self.navManeuverList = navManeuverList
        self.navStepsLatList = navStepsLatList
        self.navStepsLngList = navStepsLngList
    }
}
struct SnapToRoadsData:Codable{
    var latitude:Double
    var longitude:Double
    init(latitude:Double,longitude:Double){
        self.latitude = latitude
        self.longitude = longitude
    }
}
struct RouterAndStepData:Codable {
    let navStepsRemindList:[String]
    let navStepsTittleList:[String]
    let navManeuverList:[String]
    let navStepsLatList:[Double]
    let navStepsLngList:[Double]
    let points:[String]
    let polylinePoint:String
    init(navStepsRemindList:[String],navStepsTittleList:[String],navManeuverList:[String],navStepsLatList:[Double],navStepsLngList:[Double],points:[String],polylinePoint:String){
        self.navStepsRemindList = navStepsRemindList
        self.navStepsTittleList = navStepsTittleList
        self.navManeuverList = navManeuverList
        self.navStepsLatList = navStepsLatList
        self.navStepsLngList = navStepsLngList
        self.points = points
        self.polylinePoint = polylinePoint
    }
}
