//
//  googleMapApiUrl.swift
//  gooogleMapSearchBar
//
//  Created by 李晉杰 on 2022/11/16.
//

import Foundation
public class GoogleMapApiUrl {
    public final var textSearchUrl:String
    public final var directionsUrl:String
    public final var snapToRoadsUrl:String
    init() {
        textSearchUrl = "/maps/api/place/textsearch/json"
        directionsUrl = "/maps/api/directions/json"
        snapToRoadsUrl = "/v1/snapToRoads"
    }
}
