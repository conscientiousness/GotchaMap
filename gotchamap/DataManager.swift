//
//  DataManager.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/23.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import Foundation
import SwiftyJSON

struct DataManager {
    
    static func getPokeBaseInfoFromFile(withSuccess success: (data: JSON) -> Void) {
        if let filePath = NSBundle.mainBundle().pathForResource("pokemon", ofType:"json") {
            do {
                let data = try NSData(contentsOfFile:filePath,
                                      options: NSDataReadingOptions.DataReadingUncached)
                let json = JSON(data:data)
                success(data: json)
            } catch {
                fatalError()
            }
        } else {
            print("The local JSON file could not be found")
        }
    }
}