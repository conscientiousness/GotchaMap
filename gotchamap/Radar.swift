//
//  Radar.swift
//  gotchamap
//
//  Created by Jesselin on 2016/8/11.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import SwiftyJSON

struct Radar {
    
    let pokemonId: Int
    let latitude: Double
    let longitude: Double
    let trainerName: String
    let upvotes: Int
    let downvotes: Int
    let created: Int
    
    init(json value: JSON) {
        pokemonId = value["pokemonId"].int ?? 0
        latitude = value["latitude"].double ?? 0.0
        longitude = value["longitude"].double ?? 0.0
        trainerName  = value["trainerName"].string ?? ""
        upvotes  = value["upvotes"].int ?? 0
        downvotes  = value["downvotes"].int ?? 0
        created  = value["created"].int ?? 0
    }
}