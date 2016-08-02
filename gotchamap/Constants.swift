//
//  Constants.swift
//  gotchamap
//
//  Created by Jesselin on 2016/8/2.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

enum FirebaseRefKey {
    static let users = "users"
    static let pokemons = "pokemons"
    static let likes = "likes"
    
    enum Pokemons {
        static let Coordinate = "Coordinate"

        enum Vote {
            static let good = "good"
            static let shit = "shit"
        }
    }
}

enum UserDefaultsKey {
    static let uid = "uid"
}