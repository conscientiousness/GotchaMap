//
//  MainVC.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/20.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

class MainVC: UIViewController {

    let mapView = MKMapView()
    let numberOfLocations = 1000
    let clusteringManager = FBClusteringManager()
    let locationMananger = CLLocationManager()
    var currentLocation: CLLocation?
    var isFirstLocationReceived = false
    var basePokes: [Pokemon] = []
    
    private(set) lazy var backHomeBtn: UIButton = {
        let _backHomeBtn = UIButton()
        _backHomeBtn.setTitle("點我回家", forState: .Normal)
        _backHomeBtn.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        _backHomeBtn.backgroundColor = UIColor.whiteColor()
        _backHomeBtn.addTarget(self, action: .backHomeSelector, forControlEvents: .TouchUpInside)
        return _backHomeBtn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setUpLocationMananger()
        
        DataManager.getPokeBaseInfoFromFile { (data) in

            if data.type == .Array {

                for json in data.arrayValue {
                    let pokemon = Pokemon(json: json)
                    self.basePokes.append(pokemon)
                }
                
                let array:[MKAnnotation] = self.randomLocationsWithCount(self.numberOfLocations)
                self.clusteringManager.addAnnotations(array)
                self.mapView.centerCoordinate = CLLocationCoordinate2DMake(0, 0);
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupSubviews() {
        self.view.backgroundColor = UIColor.blackColor()
        
        self.view.addSubview(mapView)
        self.view.addSubview(backHomeBtn)
        
        clusteringManager.delegate = self;
        
        mapView.cornerRadius = 6
        mapView.delegate = self
        mapView.setUserTrackingMode(.Follow, animated: true)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        backHomeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["mapView": mapView, "backHomeBtn": backHomeBtn]
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[mapView]|", options: [], metrics: nil, views: views))
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[backHomeBtn]-8-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[backHomeBtn]", options: [], metrics: nil, views: views))
    }
    
    private func setUpLocationMananger() {
        locationMananger.requestWhenInUseAuthorization()
        locationMananger.desiredAccuracy = kCLLocationAccuracyBest
        locationMananger.delegate = self
        locationMananger.startUpdatingLocation()
    }
    
    // MARK: - Utility
    
    private func zoomInToCurrentLocation(coordinate: CLLocationCoordinate2D) {
        var region = mapView.region;
        region.center = coordinate;
        region.span.latitudeDelta=0.01;
        region.span.longitudeDelta=0.01;
        mapView.setRegion(region, animated: true)
    }
    
    func randomLocationsWithCount(count:Int) -> [FBAnnotation] {
        var array: [FBAnnotation] = []
        for _ in 0...count {
            let a: FBAnnotation = FBAnnotation()
            a.coordinate = CLLocationCoordinate2D(latitude: drand48() * 40 - 20, longitude: drand48() * 80 - 40 )
            array.append(a)
        }
        return array
    }
    
    // MARK: - Button Action Method
    
    @objc private func backHomeBtnPressed(sender: UIButton) {
        zoomInToCurrentLocation(mapView.userLocation.coordinate)
    }
}

private extension Selector {
    static let backHomeSelector = #selector(MainVC.backHomeBtnPressed(_:))
}

extension MainVC: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        
        // get user location and zoom in to current location
        if let currentLocation = currentLocation where !isFirstLocationReceived {
            zoomInToCurrentLocation(currentLocation.coordinate)
            isFirstLocationReceived = true;
        }
    }
}

extension MainVC: FBClusteringManagerDelegate {
    
    func cellSizeFactorForCoordinator(coordinator:FBClusteringManager) -> CGFloat{
        return 1.5
    }
}

extension MainVC: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        NSOperationQueue().addOperationWithBlock({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            
            let scale:Double = mapBoundsWidth / mapRectWidth

            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
        })
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        if annotation.isKindOfClass(FBAnnotationCluster) {
            let reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            
            return clusterView
            
        } else {
            let reuseId = "poke"
            var pokeView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? PokeAnnotationView
            
            if pokeView == nil {
                pokeView  = PokeAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            
            let fbAnnotation = annotation as! FBAnnotation
            pokeView?.setUpAnView(basePokes[fbAnnotation.pokeId])
            
            return pokeView
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
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation {
            if annotation.isKindOfClass(MKUserLocation) {
                return
            }
            
            if annotation.isKindOfClass(FBAnnotation) {
                let fbAnnotation = annotation as! FBAnnotation
                print(fbAnnotation.pokeId)
            }
            
            if annotation.isKindOfClass(FBAnnotation) {
                let fbAnnotation = annotation as! FBAnnotation
                print(fbAnnotation.pokeId)
            }
        }
    }
}

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
