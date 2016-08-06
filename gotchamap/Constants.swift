//
//  Constants.swift
//  gotchamap
//
//  Created by Jesselin on 2016/8/2.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

// MARK: - Firebase Refrence Key

enum FirebaseRefKey {
    static let users = "users"
    static let pokemons = "pokemons"
    static let likes = "likes"
    static let coordinates = "coordinates"
    
    enum Pokemons {
        static let coordinate = "coordinate"
        static let vote = "vote"
        
        enum Vote {
            static let good = "good"
            static let shit = "shit"
        }
    }
    
    enum Users {
        static let pokemons = "pokemons"
        static let votes = "votes"
    }
}

// MARK: - NSUserDefault Key

enum UserDefaultsKey {
    static let uid = "uid"
    static let trainerName = "trainerName"
}

// MARK: - Pokedex View Controller

enum PokedexType {
    case Normal, Report
}

// MARK: - PokeInfo View Controller

enum PokeDetailType {
    case Normal, Map
}

enum PokeDetailReportBtnType: Int {
    case Shit = 0
    case Good = 1
}