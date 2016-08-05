//
//  FBAnnotation.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class FBAnnotation : NSObject {

    var coordinate = CLLocationCoordinate2D(latitude: 25.024739, longitude: 121.468240)
    var title: String?
    var pokeId: Int?
    var objectId: String?
}

extension FBAnnotation : MKAnnotation {
    
}