//
//  GoogleMapAPI.swift
//  gooogleMapSearchBar
//
//  Created by 李晉杰 on 2022/11/16.
//

import Foundation
import SwiftyJSON
import Alamofire
class GoogleMapApi<T:Codable> {
    final let googleMapApiUrl1 = "https://maps.googleapis.com"
    final let googleMapApiUrl2 = "https://roads.googleapis.com"
    func textsearchJsonGet(keyWord:String,lat:Double,lng:Double,action: @escaping (JSON) -> ()) {
        let parameters: Parameters = [
            "location": "\(lat),\(lng)",
            "query": "\(keyWord)",
            "radius": "10000",
            "language": "zh- m",
            "key": "\(GoogleMapApiKey().googleMapKey)"
        ]
        AF.request(googleMapApiUrl1+GoogleMapApiUrl().textSearchUrl, method: .get, parameters: parameters).responseJSON { [self] response in
            switch response.result {
                case let .success(data):
                    let json = JSON(data)
                    action(json)
            case let .failure(error): print(error.localizedDescription)
            }
        }
    }
    func directionJsonGet(myLat:Double,myLng:Double,annLat:Double,annLng:Double, action: @escaping (JSON) -> ()) {
        let parameters: Parameters = [
            "origin": "\(myLat),\(myLng)",
            "destination": "\(annLat),\(annLng)",
            "mode": "driving",
            "key": "\(GoogleMapApiKey().googleMapKey)"
        ]
        AF.request(googleMapApiUrl1+GoogleMapApiUrl().directionsUrl, method: .get, parameters: parameters).responseJSON { [self] response in
            switch response.result {
                case let .success(data):
                    let json = JSON(data)
                    action(json)
            case let .failure(error): print(error.localizedDescription)
            }
        }
    }
    func snapToRoadsJsonGet(myLat:Double,myLng:Double, action: @escaping (JSON) -> ()) {
        let parameters: Parameters = [
            "path" : "\(myLat),\(myLng)",
            "key":  "\(GoogleMapApiKey().googleMapKey)"
        ]
        AF.request(googleMapApiUrl2+GoogleMapApiUrl().snapToRoadsUrl, method: .get, parameters: parameters).responseJSON { [self] response in
            switch response.result {
                case let .success(data):
                    let json = JSON(data)
                    action(json)
            case let .failure(error): print(error.localizedDescription)
            }
        }
    }
}
