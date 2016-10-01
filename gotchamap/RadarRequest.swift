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
    var minLatitude: Double?
    var maxLatitude: Double?
    var minLongitude: Double?
    var maxLongitude: Double?
    
    init?() {
        // Empty Constructor
    }
    
    // To support mapping, a class or struct just needs to implement the Mappable protocol
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        pokemonId   <- map["pokemonId"]
        minLatitude    <- map["minLatitude"]
        maxLatitude   <- map["maxLatitude"]
        minLongitude   <- map["minLongitude"]
        maxLongitude   <- map["maxLongitude"]
    }
}
