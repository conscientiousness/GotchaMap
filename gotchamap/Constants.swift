//
//  Constants.swift
//  gotchamap
//
//  Created by Jesselin on 2016/8/2.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import Foundation

enum FirebaseRefKey {
    static let users = "users"
    static let pokemons = "pokemons"
    static let likes = "likes"
    
    enum Pokemons {
        enum Coordinate {
            static let latitude = "lat"
            static let longitude = "long"
        }
        
        enum Vote {
            static let good = "good"
            static let shit = "shit"
        }
    }
}

enum UserDefaultsKey {
    static let uid = "uid"
}



