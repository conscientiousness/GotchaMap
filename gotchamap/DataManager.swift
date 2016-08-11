//
//  DataManager.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/23.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import Alamofire
import SwiftyJSON

class DataManager {
    
    static let shared = FirebaseManager()
    private let radarBaseUrl = "https://www.pokeradar.io/api/v1/submissions"
    
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
            //Debug.print("The local JSON file could not be found")
        }
    }
    
    func getRadarAPI(withRequest request: RadarRequest, success: (model: Radar) -> Void) {
        Alamofire.request(.GET, radarBaseUrl, parameters: ["": ""]).responseJSON { reponse in
            
        }
    }
}