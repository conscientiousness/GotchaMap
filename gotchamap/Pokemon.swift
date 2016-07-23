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
    
    let pokeId: String
    let img: String
    
    var imgURL: NSURL? {
        return NSURL(string: img)
    }
    
    init(json value: JSON) {
        pokeId = value["id"].string ?? ""
        img = value["img"].string ?? ""
    }
}