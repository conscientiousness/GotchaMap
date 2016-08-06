//
//  PostPoke.swift
//  gotchamap
//
//  Created by Jesselin on 2016/8/2.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import ObjectMapper

class PokeRequest: Mappable {
    var pokemonId: String?
    var trainer: String?
    var timestemp: String?
    var memo: String?
    var coordinate: [String : Double] = [:]
    var vote: [String : Int] = [:]
    
    init?() {
        // Empty Constructor
    }
    
    // To support mapping, a class or struct just needs to implement the Mappable protocol
    required init?(_ map: Map) {
       mapping(map)
    }
    
    func mapping(map: Map) {
        pokemonId   <- map["pokemonId"]
        coordinate  <- map["coordinate"]
        vote        <- map["vote"]
        trainer     <- map["trainer"]
        timestemp   <- map["timestemp"]
        memo        <- map["memo"]
    }
}