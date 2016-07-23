//
//  Pokemon.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/23.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import Foundation
import SwiftyJSON

//class Pokemon: NSObject {
//    
//    var pokeId: String = ""
//    var img: String = ""
//    
//    var imgURL: NSURL? {
//        return NSURL(string: img)
//    }
//    
//    func parsePokemon(pokemonJSON: JSON) {
//        
//        pokeId = pokemonJSON["id"].string ?? ""
//        img = pokemonJSON["img"].string ?? ""
//    }
//}

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