//
//  DataManager.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/23.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import SwiftyJSON

class DataManager {
    
    static let shared = FirebaseManager()
    
    static func getPokeBaseInfoFromFile(withSuccess success: (_ data: JSON) -> Void) {
        if let filePath = Bundle.main.path(forResource: "pokemon", ofType:"json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath),
                                      options: NSData.ReadingOptions.uncached)
                let json = JSON(data: data)
                success(json)
            } catch {
                fatalError()
            }
        } else {
            Debug.print("The local JSON file could not be found")
        }
    }
}
