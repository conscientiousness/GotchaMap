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
    static let coordinates = "coordinates"
    
    enum Pokemons {
        static let coordinate = "coordinate"
        

        enum Vote {
            static let good = "good"
            static let shit = "shit"
        }
    }
}

enum UserDefaultsKey {
    static let uid = "uid"
    static let trainerName = "trainerName"
}

enum PokedexType {
    case Normal, Report
}