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
}