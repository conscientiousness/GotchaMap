//
//  Mappable.swift
//  gotchamap
//
//  Created by Jesselin on 2016/8/2.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import Foundation
import Map

protocol Mappable {
    init?(_ map: Map)
    mutating func mapping(map: Map)
    static func objectForMapping(map: Map) -> Mappable? // Optional
}