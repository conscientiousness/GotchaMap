//
//  RadarAPIManager.swift
//  gotchamap
//
//  Created by Jesselin on 2016/9/4.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import Alamofire
import SwiftyJSON
import ObjectMapper

class RadarAPIManager {
    
    static let shared = RadarAPIManager()
    
    private let radarBaseUrl = "https://www.pokeradar.io/api/v1/submissions"
    
    func getRadarAPI(withRequest request: RadarRequest, success: (datas: Array<Radar>) -> Void) {
        Alamofire.request(.GET, radarBaseUrl, parameters: Mapper().toJSON(request)).responseJSON { response in
            
            var pokes: [Radar] = []
            if let responseVal = response.result.value {
                let json = JSON(responseVal)
                if json["data"].type == .Array  {
                    for data in json["data"].arrayValue {
                        let pokemon = Radar(json: data)
                        pokes.append(pokemon)
                    }
                }
            }
            success(datas: pokes)
        }
    }
}