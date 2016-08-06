//
//  PokemonInfos.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/24.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

class PokemonHelper {
    static let shared = PokemonHelper()
    var infos: [Pokemon] = []
    var currentLocation: CLLocation?
    
    static func trustPercent(good good: Int, shit: Int) -> Int {
        guard good + shit > 50 else {
            return 50
        }
        
        return Int(Float(good) / Float(good + shit) * 100)
    }
}