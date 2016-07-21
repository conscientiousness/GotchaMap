//
//  MainVC.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/20.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class MainVC: UIViewController {

    let mapView = MKMapView()
    let numberOfLocations = 1000
    let clusteringManager = FBClusteringManager()
    var currentScaleRate: Double?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        mapView.delegate = self
        clusteringManager.delegate = self;
        
        let array:[MKAnnotation] = randomLocationsWithCount(numberOfLocations)
        clusteringManager.addAnnotations(array)
        mapView.centerCoordinate = CLLocationCoordinate2DMake(0, 0);
    }
    
    private func setupSubviews() {
        self.view.backgroundColor = UIColor.blackColor()
        
        self.view.addSubview(mapView)
        mapView.cornerRadius = 6
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["mapView": mapView]
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[mapView]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: - Utility
    
    func randomLocationsWithCount(count:Int) -> [FBAnnotation] {
        var array:[FBAnnotation] = []
        for _ in 0...count {
            let a:FBAnnotation = FBAnnotation()
            a.coordinate = CLLocationCoordinate2D(latitude: drand48() * 40 - 20, longitude: drand48() * 80 - 40 )
            array.append(a)
        }
        return array
    }
}

extension MainVC : FBClusteringManagerDelegate {
    
    func cellSizeFactorForCoordinator(coordinator:FBClusteringManager) -> CGFloat{
        return 1.0
    }
    
}


extension MainVC : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        
        NSOperationQueue().addOperationWithBlock({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            
            let scale:Double = mapBoundsWidth / mapRectWidth
            self.currentScaleRate = scale
            
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
        })
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        
        if annotation.isKindOfClass(FBAnnotationCluster) {
            
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            
            return clusterView
            
        } else {
            
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            return pinView
        }
        
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        for view in views {
            if view.annotation is MKUserLocation {
                continue;
            }
            
            // Check if current annotation is inside visible map rect, else go to next one
            let point:MKMapPoint  =  MKMapPointForCoordinate(view.annotation!.coordinate);
            if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
                continue;
            }
            
            view.transform = CGAffineTransformMakeScale(0.85, 0.85)
            UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.4, options: .CurveEaseInOut, animations:{() in
                view.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: {(Bool) in
                    
            })
        }
    }
    
}

/*
 for annotation in mapView.annotations {
 let anView: MKAnnotationView? = mapView.viewForAnnotation(annotation)
 if let anView = anView {
 if anView.annotation is MKUserLocation {
 continue;
 }
 
 // Check if current annotation is inside visible map rect, else go to next one
 let point:MKMapPoint  =  MKMapPointForCoordinate(anView.annotation!.coordinate);
 if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
 continue;
 }
 
 view.transform = CGAffineTransformMakeScale(0.85, 0.85)
 UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.4, options: .CurveEaseInOut, animations:{() in
 anView.transform = CGAffineTransformMakeScale(1, 1)
 }, completion: {(Bool) in
 
 })
 }
 }*/

/*
 // 0. This example uses MapKit to calculate the bounding box
 import MapKit
 
 // 1. Plenty of answers for this one...
 let currentLocation = CLLocationCoordinate2DMake(37.7749295, -122.4194155)
 
 // 2. Create the bounding box with, 1km radius
 let region = MKCoordinateRegionMakeWithDistance(currentLocation, 1000, 1000)
 let northWestCorner = CLLocationCoordinate2DMake(
 currentLocation.latitude + (region.span.latitudeDelta),
 currentLocation.longitude - (region.span.longitudeDelta)
 )
 let southEastCorner = CLLocationCoordinate2DMake(
 currentLocation.latitude - (region.span.latitudeDelta),
 currentLocation.longitude + (region.span.longitudeDelta)
 )
 
 // 3. Filter your objects
 let predicate = NSPredicate(format: "lat BETWEEN {%f, %f} AND lon BETWEEN {%f, %f}",
 northWestCorner.latitude,
 southEastCorner.latitude,
 northWestCorner.longitude,
 southEastCorner.longitude
 )
 
 let nearbyLocations = realm.objects(MyLocation).filter(predicate)
 
 http://stackoverflow.com/questions/33200296/realm-filter-cllocation
 */
