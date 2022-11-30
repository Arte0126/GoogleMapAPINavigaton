//
//  googleMapVM.swift
//  gooogleMapSearchBar
//
//  Created by 李晉杰 on 2022/11/16.
//
import SwiftyJSON
import Alamofire
import Foundation

class GoogleMapM<T:Codable> {
    func textSearchDataParser(keyWord:String,lat:Double,lng:Double,action: @escaping (T) -> ()){
        var searchResultList:[String] = []
        var searchResultLatList:[Double] = []
        var searchResultLngList:[Double] = []
        let SearchAPI =  GoogleMapApi<textSearchData>()
        SearchAPI.TextsearchJsonGet(keyWord: keyWord, lat: lat, lng: lng) { SearchDataResult in
            let results = SearchDataResult["results"].array
            guard let results = results else {
                print("error")
                return
            }
            results.forEach ({
                Data in
                let name:String = Data["name"].stringValue
                let lat:Double = Data["geometry"]["location"]["lat"].double ?? 0
                let lng:Double = Data["geometry"]["location"]["lng"].double ?? 0
                searchResultList.append(name)
                searchResultLatList.append(lat)
                searchResultLngList.append(lng)
            })
            action(textSearchData .init(searchResultList: searchResultList, searchResultLatList: searchResultLatList, searchResultLngList: searchResultLngList) as! T)
        }
    }
    func mapRouteDataParser(myLat:Double,myLng:Double,annLat:Double,annLng:Double,action: @escaping (T) -> ()){
        var pointsDataList:[String] = []
        let mapRouteDataAPI = GoogleMapApi<MapRouteData>()
        mapRouteDataAPI.directionJsonGet(myLat: myLat, myLng: myLng, annLat: annLat, annLng: annLng){
            [weak self] mapRouteDataAPIResult in
            let routesData = mapRouteDataAPIResult["routes"].array
            guard let routesData = routesData else {
                print("error")
                return
            }
            let routeOverviewPolyline = routesData[0]["overview_polyline"].dictionary
            let polylinePoint = routeOverviewPolyline?["points"]?.stringValue
            routesData[0]["legs"][0]["steps"].arrayValue.forEach ({
                stepsData in
                let pointsData = stepsData["polyline"]["points"].stringValue
                pointsDataList.append(pointsData)
            })
            action(MapRouteData.init(points: pointsDataList,polylinePoint: polylinePoint ?? "") as! T)
        }
    }
    
//    func directionDataParser(myLat:Double,myLng:Double,annLat:Double,annLng:Double,action: @escaping (T) -> ()){
//        var pointsDataList:[String] = []
//        let directionDataAPI = GoogleMapApi<T>()
//        directionDataAPI.directionJsonGet(myLat: myLat, myLng: myLng, annLat: annLat, annLng: annLng){
//            [weak self] mapRouteDataAPIResult in
//            let routesData = mapRouteDataAPIResult["routes"].array
//            guard let routesData = routesData else {
//                print("error")
//                return
//            }
//            let routeOverviewPolyline = routesData[0]["overview_polyline"].dictionary
//            let polylinePoint = routeOverviewPolyline?["points"]?.stringValue
//            routesData[0]["legs"][0]["steps"].arrayValue.forEach ({
//                stepsData in
//                let pointsData = stepsData["polyline"]["points"].stringValue
//                pointsDataList.append(pointsData)
//            })
//            action(MapRouteData.init(points: pointsDataList,polylinePoint: polylinePoint ?? "") as! T)
//            
//            var navManeuverList:[String] = []
//            var navStepsRemindDataList:[String] = []
//            var navStepsTittleList:[String]=[]
//            var navStepsLatList:[Double] = []
//            var navStepsLngList:[Double] = []
//            routesData[0]["legs"][0]["steps"].arrayValue.forEach ({
//                stepsData in
//                let navStepsLatVal:Double = stepsData["start_location"]["lat"].double ?? 0
//                navStepsLatList.append(navStepsLatVal)
//                let navStepsLngVal:Double = stepsData["start_location"]["lng"].double ?? 0
//                navStepsLngList.append(navStepsLngVal)
//                let navManeuver = stepsData["maneuver"].stringValue
//                navManeuverList.append(navManeuver)
//                let navStepsRemindData = stepsData["html_instructions"].stringValue
//                let navStepsRemindVal = NavWorldSplit().navStepsRemindProcess(navStepsRemindData: navStepsRemindData)
//                navStepsRemindDataList.append(navStepsRemindVal)
//                let navStepsTittleVal = NavWorldSplit().navStepsTittleProcess(navStepsRemindData: navStepsRemindData)
//                navStepsTittleList.append(navStepsTittleVal)
//            })
//            print(navStepsTittleList)
////            action(NavigationData.init(navStepsRemindList: navStepsRemindDataList, navStepsTittleList: navStepsTittleList, navManeuverList: navManeuverList, navStepsLatList: navStepsLatList, navStepsLngList: navStepsLngList) as! T)
//        }
//    }
    
    func NavigationParser(myLat:Double,myLng:Double,annLat:Double,annLng:Double,action: @escaping (T) -> ()) {
        var navManeuverList:[String] = []
        var navStepsRemindDataList:[String] = []
        var navStepsTittleList:[String]=[]
        var navStepsLatList:[Double] = []
        var navStepsLngList:[Double] = []
        let NavigationDataAPI = GoogleMapApi<NavigationData>()
        NavigationDataAPI.directionJsonGet(myLat: myLat, myLng: myLng, annLat: annLat, annLng: annLng){
            [weak self] NavigationDataAPIResult in
            let routesData = NavigationDataAPIResult["routes"].array
            guard let routesData = routesData else {
                print("error")
                return
            }
            routesData[0]["legs"][0]["steps"].arrayValue.forEach ({
                stepsData in
                let navStepsLatVal:Double = stepsData["start_location"]["lat"].double ?? 0
                navStepsLatList.append(navStepsLatVal)
                let navStepsLngVal:Double = stepsData["start_location"]["lng"].double ?? 0
                navStepsLngList.append(navStepsLngVal)
                let navManeuver = stepsData["maneuver"].stringValue
                navManeuverList.append(navManeuver)
                let navStepsRemindData = stepsData["html_instructions"].stringValue
                let navStepsRemindVal = NavWorldSplit().navStepsRemindProcess(navStepsRemindData: navStepsRemindData)
                navStepsRemindDataList.append(navStepsRemindVal)
                let navStepsTittleVal = NavWorldSplit().navStepsTittleProcess(navStepsRemindData: navStepsRemindData)
                navStepsTittleList.append(navStepsTittleVal)
            })
            action(NavigationData.init(navStepsRemindList: navStepsRemindDataList, navStepsTittleList: navStepsTittleList, navManeuverList: navManeuverList, navStepsLatList: navStepsLatList, navStepsLngList: navStepsLngList) as! T)
        }
    }
    
    func snapToRoadsParser(myLat:Double,myLng:Double,action: @escaping (T) -> ()){
        let snapToRoadsAPI = GoogleMapApi<snapToRoadsData>()
        snapToRoadsAPI.snapToRoadsJsonGet(myLat: myLat, myLng: myLng){
            [weak self] snapToRoadsAPIResult in
            let snappedPointsData = snapToRoadsAPIResult["snappedPoints"].array
            guard let snappedPointsData = snappedPointsData else {
                print("error")
                return
            }
            let snappedLat = snappedPointsData[0]["location"]["latitude"].double
            let snappedLng = snappedPointsData[0]["location"]["longitude"].double
            action(snapToRoadsData.init(latitude: snappedLat ?? 0,longitude: snappedLng ?? 0 ) as! T)
        }
    }
}
