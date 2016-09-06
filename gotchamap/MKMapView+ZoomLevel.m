//
//  MKMapView+MKMapView_ZoomLevel.m
//  gotchamap
//
//  Created by Jesselin on 2016/9/7.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

#import "MKMapView+ZoomLevel.h"

@implementation MKMapView (ZoomLevel)

- (double)zoomLevel{
    CLLocationDegrees longitudeDelta = self.region.span.longitudeDelta;
    CGFloat mapWidthInPixels = self.bounds.size.width;
    double zoomScale = longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * mapWidthInPixels);
    double zoomer = MAX_GOOGLE_LEVELS - log2( zoomScale );
    if ( zoomer < 0 ) zoomer = 0;
    
    return zoomer;
}

@end
