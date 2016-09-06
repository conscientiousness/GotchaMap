//
//  MKMapView+MKMapView_ZoomLevel.h
//  gotchamap
//
//  Created by Jesselin on 2016/9/7.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

#import <MapKit/MapKit.h>
#define MERCATOR_RADIUS 85445659.44705395
#define MAX_GOOGLE_LEVELS 20

@import UIKit;

@interface MKMapView (ZoomLevel)
- (double)zoomLevel;
@end
