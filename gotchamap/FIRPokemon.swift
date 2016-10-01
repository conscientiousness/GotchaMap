//
//  FIRPokemon.swift
//  gotchamap
//
//  Created by Jesselin on 2016/8/7.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import SwiftyJSON

class FIRPokemon {
    
    let pokeId: String
    let memo: String
    let timestemp: String
    let trainer: String
    var goodCount: Int
    var shitCount: Int
    let lat: Double
    let long: Double
    
    init(json value: JSON) {
        pokeId = value["pokemonId"].string ?? ""
        memo = value["memo"].string ?? ""
        timestemp = value["timestemp"].string ?? ""
        trainer  = value["trainer"].string ?? ""
        
        let voteDict: [String: JSON] = value["vote"].dictionaryValue
        goodCount = voteDict["good"]?.int ?? 0
        shitCount = voteDict["shit"]?.int ?? 0
        
        
        let coordinateDict: [String: JSON] = value["coordinate"].dictionaryValue
        if let locationArray: [JSON] = coordinateDict["l"]?.arrayValue, locationArray.count >= 2 {
            lat = FirebaseManager.shared.format(withLocation: locationArray[0].doubleValue)
            long = FirebaseManager.shared.format(withLocation: locationArray[1].doubleValue)
        } else {
            lat = 0.0
            long = 0.0
        }
    }
    
    func adjustTrustCount(goodVal: Int, shitVal: Int) {
        goodCount = (goodCount + goodVal) < 0 ? 0 : goodCount + goodVal
        shitCount = (shitCount + shitVal) < 0 ? 0 : shitCount + shitVal
    }
}
