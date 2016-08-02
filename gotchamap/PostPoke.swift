//
//  PostPoke.swift
//  gotchamap
//
//  Created by Jesselin on 2016/8/2.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import ObjectMapper

class PostPoke: Mappable {
    var pokemonId: String?
    var coordinate: [String : Double] = [:]
    var vote: [String : Int] = [:]
    
    // To support mapping, a class or struct just needs to implement the Mappable protocol
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        pokemonId   <- map["pokemonId"]
        coordinate  <- map["coordinate"]
        vote        <- map["vote"]
    }
}