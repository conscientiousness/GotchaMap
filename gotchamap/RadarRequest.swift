//
//  RadarRequest.swift
//  gotchamap
//
//  Created by Jesselin on 2016/8/11.
//  Copyright © 2016年 JesseLin. All rights reserved.
//
import ObjectMapper

class RadarRequest: Mappable {
    var pokemonId: Int?
    var latitude: Double?
    var longitude: Double?
    var zoomLevel: Float?
    
    init?() {
        // Empty Constructor
    }
    
    // To support mapping, a class or struct just needs to implement the Mappable protocol
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        pokemonId   <- map["pokemonId"]
        latitude    <- map["latitude"]
        longitude   <- map["longitude"]
        zoomLevel   <- map["zoomLevel"]
    }
}