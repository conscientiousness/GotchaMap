//
//  FirebaseManager.swift
//  gotchamap
//
//  Created by Jesselin on 2016/8/2.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import Firebase
import ObjectMapper

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private(set) lazy var baseRef: FIRDatabaseReference = FIRDatabase.database().reference()
    private(set) lazy var postsRef: FIRDatabaseReference = self.baseRef.child(FirebaseRefKey.pokemons)
    private(set) lazy var usersRef: FIRDatabaseReference = self.baseRef.child(FirebaseRefKey.users)
    private(set) lazy var geoFire: GeoFire = GeoFire(firebaseRef: self.baseRef.child(FirebaseRefKey.coordinates))
    
    typealias userCreatedResult = Bool? -> Void
    
    lazy var currentUsersRef: FIRDatabaseReference = {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKey.uid) as! String
        let user = self.usersRef.child(uid)
        return user
    }()
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        NSUserDefaults.standardUserDefaults().setValue(uid, forKey: UserDefaultsKey.uid)
        usersRef.child(uid).updateChildValues(user)
    }
    
    func anonymousUserSignIn(withCompletionHandler result: userCreatedResult?) {
        FIRAuth.auth()?.signInAnonymouslyWithCompletion({ (user, error) in
            if let user = user where error == nil {
                NSUserDefaults.standardUserDefaults().setValue(user.uid, forKey: UserDefaultsKey.uid)
                self.usersRef.child(user.uid).updateChildValues(["provider": "anonymous"])

                if let result = result {
                    result(true)
                }
            }
        })
    }
    
    func reportLocation(withRequestModel model: PokeRequest) {
        
        let JSONString = Mapper().toJSON(model)
        
        let pokePost = FirebaseManager.shared.postsRef.childByAutoId()
        pokePost.setValue(JSONString)
        
        if let currentCoordinate = PokemonHelper.shared.currentLocation?.coordinate {
            let location = CLLocation(latitude: format(withLocation: currentCoordinate.latitude), longitude: format(withLocation: currentCoordinate.longitude))
            GeoFire(firebaseRef: pokePost).setLocation(location, forKey: FirebaseRefKey.Pokemons.coordinate)
            FirebaseManager.shared.geoFire.setLocation(location, forKey: pokePost.key)
            
            let userPostsRef = FirebaseManager.shared.currentUsersRef.child(FirebaseRefKey.pokemons).child(pokePost.key)
            userPostsRef.setValue(true)
        }
    }
    
    func format(withLocation location: Double) -> Double {
         return Double(NSString(format:"%.6f",location) as String)!
    }
    
    func random(num: Double) -> Double {
        return Double(NSString(format:"%.6f",num - drand48() / 1000.0) as String)!
    }
}