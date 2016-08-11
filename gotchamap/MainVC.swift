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
import ObjectMapper
import Firebase

class MainVC: UIViewController {
    
    private lazy var mapView: MKMapView = {
        let _mapView = MKMapView()
        _mapView.cornerRadius = 10
        _mapView.delegate = self
        _mapView.setUserTrackingMode(.Follow, animated: true)
        return _mapView
    }()
    
    private lazy var clusteringManager: FBClusteringManager = {
        let _clusteringManager = FBClusteringManager()
        _clusteringManager.delegate = self;
        return _clusteringManager
    }()
    
    private lazy var locationMananger: CLLocationManager = {
        let _locationMananger = CLLocationManager()
        _locationMananger.delegate = self;
        _locationMananger.requestWhenInUseAuthorization()
        _locationMananger.desiredAccuracy = kCLLocationAccuracyBest
        return _locationMananger
    }()

    private lazy var backHomeBtn: UIButton = {
        let _backHomeBtn = UIButton()
        _backHomeBtn.setImage(UIImage(named: "btn_backHome"), forState: .Normal)
        _backHomeBtn.imageView?.contentMode = .ScaleAspectFit
        _backHomeBtn.backgroundColor = UIColor.clearColor()
        _backHomeBtn.addTarget(self, action: .backHomeBtnSelector, forControlEvents: .TouchUpInside)
        return _backHomeBtn
    }()
    
    private lazy var pokedexBtn: UIButton = {
        let _pokedexBtn = UIButton()
        _pokedexBtn.setImage(UIImage(named: "btn_pokedex"), forState: .Normal)
        _pokedexBtn.imageView?.contentMode = .ScaleAspectFit
        _pokedexBtn.backgroundColor = UIColor.clearColor()
        _pokedexBtn.addTarget(self, action: .pokedexBtnSelector, forControlEvents: .TouchUpInside)
        return _pokedexBtn
    }()
    
    private lazy var repotPokeBtn: UIButton = {
        let _pokedexBtn = UIButton()
        _pokedexBtn.setImage(UIImage(named: "btn_add_pokemon_location"), forState: .Normal)
        _pokedexBtn.imageView?.contentMode = .ScaleAspectFit
        _pokedexBtn.backgroundColor = UIColor.clearColor()
        _pokedexBtn.addTarget(self, action: .reportBtnSelector, forControlEvents: .TouchUpInside)
        return _pokedexBtn
    }()
    
    private lazy var transition: BubbleTransition = {
        let _transition = BubbleTransition()
        _transition.bubbleColor = Palette.Pokedex.Background
        return _transition
    }()
    
    private lazy var circleQuery :GFCircleQuery = {
        let center = CLLocation(latitude: 0, longitude: 0)
        return FirebaseManager.shared.geoFire.queryAtLocation(center, withRadius: 5.0)
    }()
    
    //let numberOfLocations = 1000 //for test
    var isFirstLocationReceived = false
    var clusteringDict:[String: FBAnnotation] = [:]
    // km
    var queryRadius = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        DataManager.getPokeBaseInfoFromFile { (data) in

            if data.type == .Array {
                for json in data.arrayValue {
                    let pokemon = Pokemon(json: json)
                    PokemonHelper.shared.infos.append(pokemon)
                }
                
                // for test
                /*let array:[MKAnnotation] = self.randomLocationsWithCount(self.numberOfLocations)
                self.clusteringManager.addAnnotations(array)
                self.mapView.centerCoordinate = CLLocationCoordinate2DMake(0, 0);*/
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
        locationMananger.startUpdatingLocation()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        locationMananger.stopUpdatingLocation()
    }
    
    private func setupSubviews() {
        view.addSubview(mapView)
        view.addSubview(backHomeBtn)
        view.addSubview(pokedexBtn)
        view.addSubview(repotPokeBtn)
        
        self.view.backgroundColor = UIColor.blackColor()
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        backHomeBtn.translatesAutoresizingMaskIntoConstraints = false
        pokedexBtn.translatesAutoresizingMaskIntoConstraints = false
        repotPokeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["mapView": mapView, "backHomeBtn": backHomeBtn, "pokedexBtn": pokedexBtn, "reportPokeBtn": repotPokeBtn]
        let metrics = ["btnSize": 60, "btnMargin": 15]
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[mapView]|", options: [], metrics: nil, views: views))
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[backHomeBtn(btnSize)]-btnMargin-|", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-btnMargin-[backHomeBtn(btnSize)]", options: [], metrics: metrics, views: views))
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pokedexBtn(btnSize)]-btnMargin-|", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[pokedexBtn(btnSize)]-btnMargin-|", options: [], metrics: metrics, views: views))
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[reportPokeBtn(btnSize)]-btnMargin-|", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[reportPokeBtn(btnSize)]", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: repotPokeBtn, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)])
    }
    
    // MARK: - fetch Data
    
    func updateCircleQuery() {

        let centerCoordinate = mapView.convertPoint(mapView.center, toCoordinateFromView: view)
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        circleQuery.center = centerLocation
        circleQuery.radius = queryRadius
        Debug.print("queryRadius = \(queryRadius)")
    }
    
    func setupObservers() {
        
        circleQuery.observeEventType(.KeyEntered, withBlock: { (key: String!, location: CLLocation!) in
            Debug.print("KeyEntered")
            let an: FBAnnotation = FBAnnotation()
            an.coordinate = location.coordinate
            an.objectId = key
            
            FirebaseManager.shared.postsRef.child(key).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let value = snapshot.value {
                    if let pokeId: Int = Int((value["pokemonId"] as! String)) {
                        an.pokeId = pokeId
                        
                        //self.clusteringManager.addAnnotations([an])
                        self.clusteringDict[key] = an
                        self.mapView.addAnnotation(an)
                        //Debug.print("pokeid = \(pokeId) ,key = \(key)")
                    }
                }
            })
        })
        
        circleQuery.observeEventType(.KeyExited, withBlock: { (key: String!, location: CLLocation!) in
            Debug.print("KeyExited")
            
            if let fbAnnotation = self.clusteringDict[key] {
                self.mapView.removeAnnotation(fbAnnotation)
                self.clusteringDict.removeValueForKey(key)
                //self.clusteringManager = FBClusteringManager()
                //self.clusteringManager.delegate = self;
            }
        })
        
        circleQuery.observeEventType(.KeyMoved, withBlock: { (key: String!, location: CLLocation!) in
            Debug.print("KeyMoved")
        })
        
        circleQuery.observeReadyWithBlock({
            //Debug.print("observeReadyWithBlock")
        })
        
    }
    
    // MARK: - Utility
    
    private func zoomInToCurrentLocation(coordinate: CLLocationCoordinate2D?, level: Double) {
        
        if let coordinate = coordinate {
            var region = mapView.region;
            region.center = coordinate;
            region.span.latitudeDelta = level;
            region.span.longitudeDelta = level;
            mapView.setRegion(region, animated: true)
        }
    }
    
    /*/ for test
    func randomLocationsWithCount(count:Int) -> [FBAnnotation] {
        var array: [FBAnnotation] = []
        for _ in 0...count {
            let a: FBAnnotation = FBAnnotation()
            a.coordinate = CLLocationCoordinate2D(latitude: drand48() * 70 - 20, longitude: drand48() * 170 - 40 )
            array.append(a)
        }
        return array
    }*/
    
    func checkLocationPermission() -> Bool {
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            return true
        case .NotDetermined:
            locationMananger.requestWhenInUseAuthorization()
            return false
        case .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "沒有開啟定位資訊", // Background Location Access Disabled
                message: "位置權限請選擇 '使用App期間' 或 '永遠', 才能搜尋或回報目前位置資訊",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil) //Cancel
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "打開設定", style: .Default) { (action) in // Open Settings
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
    }
    
    // MARK: - Button Action Method
    
    @objc private func backHomeBtnPressed(sender: UIButton) {
        if checkLocationPermission() {
            zoomInToCurrentLocation(mapView.userLocation.coordinate, level: 0.01)
        }
    }
    
    @objc private func pokedexBtnPressed(sender: UIButton) {
        let targetVC = PokedexVC(pokedexType: .Normal)
        targetVC.transitioningDelegate = self
        targetVC.modalPresentationStyle = .Custom
        transition.startingPoint = self.pokedexBtn.center
        self.presentViewController(targetVC, animated: true, completion: nil)
    }
    
    @objc private func reportBtnPressed(sender: UIButton) {
        if checkLocationPermission() {
            let targetVC = PokedexVC(pokedexType: .Report)
            targetVC.transitioningDelegate = self
            targetVC.modalPresentationStyle = .Custom
            transition.startingPoint = self.repotPokeBtn.center
            self.presentViewController(targetVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - FBClusteringMap
    
    private func refreshClusteringAnnotations() {
        NSOperationQueue().addOperationWithBlock({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            
            let scale:Double = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
            })
        })
    }
}

private extension Selector {
    static let backHomeBtnSelector = #selector(MainVC.backHomeBtnPressed(_:))
    static let pokedexBtnSelector = #selector(MainVC.pokedexBtnPressed(_:))
    static let reportBtnSelector = #selector(MainVC.reportBtnPressed(_:))
}

// MARK: - UIViewController Transitioning Delegate

extension MainVC: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        return transition
    }
}

// MARK: - CLLocation Manager Delegate

extension MainVC: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        PokemonHelper.shared.currentLocation = locations.last
        
        // get user location and zoom in to current location
        if let currentLocation = PokemonHelper.shared.currentLocation where !isFirstLocationReceived {
            var region = mapView.region;
            region.center = currentLocation.coordinate;
            region.span.latitudeDelta = 0.05;
            region.span.longitudeDelta = 0.05;
            mapView.setRegion(region, animated: false)
            isFirstLocationReceived = true
            updateCircleQuery()
            setupObservers()
        }
    }
}

// MARK: - FBClustering Manager Delegate

extension MainVC: FBClusteringManagerDelegate {
    
    func cellSizeFactorForCoordinator(coordinator:FBClusteringManager) -> CGFloat{
        return 1.5
    }
    
    func didAddAnnotation() {
        refreshClusteringAnnotations()
    }
}

// MARK: - MKMapView Delegate

extension MainVC: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        
        queryRadius = mapView.region.distanceMax()
        //refreshClusteringAnnotations()
        updateCircleQuery()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        if annotation.isKindOfClass(FBAnnotationCluster) {
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(kFBAnnotationClusterViewId)
            
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: kFBAnnotationClusterViewId, options: nil)

            return clusterView
            
        } else {
            var pokeView = mapView.dequeueReusableAnnotationViewWithIdentifier(kPokeAnnotationViewId) as? PokeAnnotationView
            
            if pokeView == nil {
                pokeView  = PokeAnnotationView(annotation: annotation, reuseIdentifier: kPokeAnnotationViewId)
            }
            
            if let fbAnnotation = annotation as? FBAnnotation, pokeId = fbAnnotation.pokeId {
                var pokeModel: Pokemon = PokemonHelper.shared.infos[pokeId - 1]
                pokeModel.objectId = fbAnnotation.objectId ?? ""
                fbAnnotation.title = pokeModel.name
                pokeView?.setUpAnView(pokeModel)
            }
            return pokeView
        }
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for view in views {
            if view.annotation is MKUserLocation {
                continue;
            }
            
            // Check if current annotation is inside visible map rect, else go to next one
            let point:MKMapPoint = MKMapPointForCoordinate(view.annotation!.coordinate);
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
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.isKindOfClass(PokeAnnotationView) {
            if let pokeModel = (view as? PokeAnnotationView)?.pokeModel {
                let targetVC = PokeInfoVC(withPokeModel: pokeModel, pokeDetailType: .Map)
                self.presentViewController(targetVC, animated: true, completion: nil)
            }
        }
    }
}

extension MKCoordinateRegion {
    func distanceMax() -> CLLocationDistance {
        let furthest = CLLocation(latitude: center.latitude + (span.latitudeDelta/2),
                                  longitude: center.longitude + (span.longitudeDelta/2))
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return centerLoc.distanceFromLocation(furthest) / 1000.0
    }
}
