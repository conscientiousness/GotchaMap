//
//  Pokemon.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/23.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import SwiftyJSON

struct Pokemon {
    
    var objectId: String?
    let pokeId: Int
    let img: String
    let name: String
    let weight: String
    let height: String
    let type: [String]
    let weakness: [String]

    var imgURL: URL? {
        return URL(string: img)
    }
    
    var typeDesc: String {
        return combineString(type)
    }
    
    var weaknessDesc: String {
        return combineString(weakness)
    }
    
    init(json value: JSON) {
        pokeId = value["id"].int ?? 0
        img = value["img"].string ?? ""
        name = value["name"].string ?? ""
        weight  = value["weight"].string ?? ""
        height  = value["height"].string ?? ""
        type = (value["type"].arrayObject as? [String]) ?? [""]
        weakness = (value["weaknesses"].arrayObject as? [String]) ?? [""]
    }
    
    fileprivate func combineString(_ arr: [String]) -> String {
        var desc: String = ""
        for (index, element) in arr.enumerated() {
            desc += index == 0 ? element : " \\ \(element)"
        }
        return desc
    }
}
