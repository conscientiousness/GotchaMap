//
//  Pokemon.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/23.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Pokemon {
    
    let pokeId: Int
    let img: String
    let name: String
    
    var imgURL: NSURL? {
        return NSURL(string: img)
    }
    
    init(json value: JSON) {
        pokeId = value["id"].int ?? 0
        img = value["img"].string ?? ""
        name = value["name"].string ?? ""
    }
}