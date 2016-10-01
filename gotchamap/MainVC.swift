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
    
    fileprivate lazy var mapView: MKMapView = {
        let _mapView = MKMapView()
        _mapView.cornerRadius = 10
        _mapView.delegate = self
        _mapView.setUserTrackingMode(.follow, animated: true)
        return _mapView
    }()
    
    fileprivate lazy var clusteringManager: FBClusteringManager = {
        let _clusteringManager = FBClusteringManager()
        _clusteringManager.delegate = self;
        return _clusteringManager
    }()
    
    fileprivate lazy var locationMananger: CLLocationManager = {
        let _locationMananger = CLLocationManager()
        _locationMananger.delegate = self;
        _locationMananger.requestWhenInUseAuthorization()
        _locationMananger.desiredAccuracy = kCLLocationAccuracyBest
        return _locationMananger
    }()

    fileprivate lazy var backHomeBtn: UIButton = {
        let _backHomeBtn = UIButton()
        _backHomeBtn.setImage(UIImage(named: "btn_backHome"), for: UIControlState())
        _backHomeBtn.imageView?.contentMode = .scaleAspectFit
        _backHomeBtn.backgroundColor = UIColor.clear
        _backHomeBtn.addTarget(self, action: .backHomeBtnSelector, for: .touchUpInside)
        return _backHomeBtn
    }()
    
    fileprivate lazy var pokedexBtn: UIButton = {
        let _pokedexBtn = UIButton()
        _pokedexBtn.setImage(UIImage(named: "btn_pokedex"), for: UIControlState())
        _pokedexBtn.imageView?.contentMode = .scaleAspectFit
        _pokedexBtn.backgroundColor = UIColor.clear
        _pokedexBtn.addTarget(self, action: .pokedexBtnSelector, for: .touchUpInside)
        return _pokedexBtn
    }()
    
    fileprivate lazy var repotPokeBtn: UIButton = {
        let _pokedexBtn = UIButton()
        _pokedexBtn.setImage(UIImage(named: "btn_add_pokemon_location"), for: UIControlState())
        _pokedexBtn.imageView?.contentMode = .scaleAspectFit
        _pokedexBtn.backgroundColor = UIColor.clear
        _pokedexBtn.addTarget(self, action: .reportBtnSelector, for: .touchUpInside)
        return _pokedexBtn
    }()
    
    fileprivate lazy var transition: BubbleTransition = {
        let _transition = BubbleTransition()
        _transition.bubbleColor = Palette.Pokedex.Background!
        return _transition
    }()
    
    fileprivate lazy var circleQuery :GFCircleQuery = {
        let center = CLLocation(latitude: 0, longitude: 0)
        return FirebaseManager.shared.geoFire.query(at: center, withRadius: 5.0)
    }()
    
    let loadingView = MapLoadingView()
    
    //let numberOfLocations = 1000 //for test
    var isFirstLocationReceived = false
    var clusteringDict: [String: FBAnnotation] = [:]
    // km
    var queryRadius = 5.0
    var request = RadarRequest()!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        setupPokeBaseData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        locationMananger.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationMananger.stopUpdatingLocation()
    }
    
    fileprivate func setupSubviews() {
        view.addSubview(mapView)
        view.addSubview(backHomeBtn)
        view.addSubview(pokedexBtn)
        view.addSubview(repotPokeBtn)
        view.addSubview(loadingView)
        
        self.view.backgroundColor = UIColor.black
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        backHomeBtn.translatesAutoresizingMaskIntoConstraints = false
        pokedexBtn.translatesAutoresizingMaskIntoConstraints = false
        repotPokeBtn.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["mapView": mapView, "backHomeBtn": backHomeBtn, "pokedexBtn": pokedexBtn, "reportPokeBtn": repotPokeBtn, "loading": loadingView] as [String : Any]
        let metrics = ["btnSize": 60, "btnMargin": 15]
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mapView]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[mapView]|", options: [], metrics: nil, views: views))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-25-[loading(40)]", options: [], metrics: nil, views: views))
        //NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[loading(100)]", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate([NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)])
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[backHomeBtn(btnSize)]-btnMargin-|", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-btnMargin-[backHomeBtn(btnSize)]", options: [], metrics: metrics, views: views))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[pokedexBtn(btnSize)]-btnMargin-|", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:[pokedexBtn(btnSize)]-btnMargin-|", options: [], metrics: metrics, views: views))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[reportPokeBtn(btnSize)]-btnMargin-|", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:[reportPokeBtn(btnSize)]", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activate([NSLayoutConstraint(item: repotPokeBtn, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)])
    }
    
    fileprivate func setupPokeBaseData() {
        DataManager.getPokeBaseInfoFromFile { (data) in
            
            if data.type == .array {
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
    
    // MARK: - Fetch Data From Firebase
    
    func updateCircleQuery() {

        let centerCoordinate = mapView.convert(mapView.center, toCoordinateFrom: view)
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        circleQuery.center = centerLocation
        circleQuery.radius = queryRadius
        Debug.print("queryRadius = \(queryRadius)")
    }
    
    func setupObservers() {
        
        circleQuery.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in

            if let key = key, let location = location {
                let an: FBAnnotation = FBAnnotation()
                an.coordinate = location.coordinate
                an.objectId = key
                
                FirebaseManager.shared.postsRef.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? [String: AnyObject] {
                        if let pokeId = Int(value["pokemonId"] as! String) {
                            if pokeId > 0 {
                                an.pokeId = pokeId
                                //Debug.print("pokeid = \(pokeId) ,key = \(key)")
                                //self.clusteringManager.addAnnotations([an])
                                self.clusteringDict[key] = an
                                self.mapView.addAnnotation(an)
                            }
                        }
                    }
                })
            }
        })
        
        circleQuery.observe(.keyExited, with: { (key: String?, location: CLLocation?) in
            //Debug.print("KeyExited")
            
            if let key = key {
                if let fbAnnotation = self.clusteringDict[key] {
                    self.mapView.removeAnnotation(fbAnnotation)
                    self.clusteringDict.removeValue(forKey: key)
                    //self.clusteringManager = FBClusteringManager()
                    //self.clusteringManager.delegate = self;
                }
            }
        })
    }

    // MARK: - Fetch Data From Radar
    
    func updateLocationRange() {
        
        // left top : max lat, min long
        let leftTopCoordinate = mapView.convert(CGPoint(x: 0, y: 0), toCoordinateFrom: mapView)
        
        // right bottom : min lat, max long
        let rightBottomCoordinate = mapView.convert(CGPoint(x: view.frame.width, y: view.frame.height), toCoordinateFrom: mapView)
        
        request.pokemonId = 0
        request.minLatitude = rightBottomCoordinate.latitude
        request.maxLatitude = leftTopCoordinate.latitude
        request.minLongitude = leftTopCoordinate.longitude
        request.maxLongitude = rightBottomCoordinate.longitude
        
        if mapView.zoomLevel() > 8 {
            fetchRadarAPI()
        }
    }
    
    func fetchRadarAPI() {
        loadingView.show()
        
        RadarAPIManager.shared.getRadarAPI(withRequest: request) { datas in
            //Debug.print("datas = \(datas)")
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            for (_, model) in datas.enumerated() {
                let an: FBAnnotation = FBAnnotation()
                an.coordinate = CLLocationCoordinate2D(latitude: model.latitude, longitude: model.longitude)
                an.pokeId = model.pokemonId
                self.mapView.addAnnotation(an)
            }
            
            self.loadingView.hide()
        }
    }
    
    // MARK: - Utility
    
    fileprivate func zoomInToCurrentLocation(_ coordinate: CLLocationCoordinate2D?, level: Double) {
        
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
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined:
            locationMananger.requestWhenInUseAuthorization()
            return false
        case .restricted, .denied:
            let alertController = UIAlertController(
                title: "沒有開啟定位資訊", // Background Location Access Disabled
                message: "位置權限請選擇 '使用App期間' 或 '永遠', 才能搜尋或回報目前位置資訊",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil) //Cancel
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "打開設定", style: .default) { (action) in // Open Settings
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.present(alertController, animated: true, completion: nil)
            return false
        }
    }
    
    // MARK: - Button Action Method
    
    @objc fileprivate func backHomeBtnPressed(_ sender: UIButton) {
        if checkLocationPermission() {
            zoomInToCurrentLocation(mapView.userLocation.coordinate, level: 0.01)
        }
    }
    
    @objc fileprivate func pokedexBtnPressed(_ sender: UIButton) {
        let targetVC = PokedexVC(pokedexType: .normal)
        targetVC.transitioningDelegate = self
        targetVC.modalPresentationStyle = .custom
        transition.startingPoint = self.pokedexBtn.center
        self.present(targetVC, animated: true, completion: nil)
    }
    
    @objc fileprivate func reportBtnPressed(_ sender: UIButton) {
        if checkLocationPermission() {
            let targetVC = PokedexVC(pokedexType: .report)
            targetVC.transitioningDelegate = self
            targetVC.modalPresentationStyle = .custom
            transition.startingPoint = self.repotPokeBtn.center
            self.present(targetVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - FBClusteringMap
    
    fileprivate func refreshClusteringAnnotations() {
        OperationQueue().addOperation({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            
            let scale:Double = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            
            OperationQueue.main.addOperation({
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
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        return transition
    }
}

// MARK: - CLLocation Manager Delegate

extension MainVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        PokemonHelper.shared.currentLocation = locations.last
        
        // get user location and zoom in to current location
        if let currentLocation = PokemonHelper.shared.currentLocation , !isFirstLocationReceived {
            var region = mapView.region;
            region.center = currentLocation.coordinate;
            region.span.latitudeDelta = 0.05;
            region.span.longitudeDelta = 0.05;
            mapView.setRegion(region, animated: false)
            isFirstLocationReceived = true
            //updateCircleQuery()
            //setupObservers()
            updateLocationRange()
        }
    }
}

// MARK: - FBClustering Manager Delegate

extension MainVC: FBClusteringManagerDelegate {
    
    func cellSizeFactorForCoordinator(_ coordinator:FBClusteringManager) -> CGFloat{
        return 1.5
    }
    
    func didAddAnnotation() {
        refreshClusteringAnnotations()
    }
}

// MARK: - MKMapView Delegate

extension MainVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        
        queryRadius = mapView.region.distanceMax()
        ////refreshClusteringAnnotations()
        //updateCircleQuery()
        updateLocationRange()
        //Debug.print("zoomLevel = " + String(mapView.zoomLevel()))
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        if annotation is FBAnnotationCluster {
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: kFBAnnotationClusterViewId)
            
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: kFBAnnotationClusterViewId, options: nil)

            return clusterView
            
        } else {
            var pokeView = mapView.dequeueReusableAnnotationView(withIdentifier: kPokeAnnotationViewId) as? PokeAnnotationView
            
            if pokeView == nil {
                pokeView  = PokeAnnotationView(annotation: annotation, reuseIdentifier: kPokeAnnotationViewId)
            }
            
            if let fbAnnotation = annotation as? FBAnnotation, let pokeId = fbAnnotation.pokeId {
                var pokeModel: Pokemon = PokemonHelper.shared.infos[pokeId - 1]
                pokeModel.objectId = fbAnnotation.objectId ?? ""
                fbAnnotation.title = pokeModel.name
                pokeView?.setUpAnView(pokeModel)
            }
            return pokeView
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            if view.annotation is MKUserLocation {
                continue;
            }
            
            // Check if current annotation is inside visible map rect, else go to next one
            let point:MKMapPoint = MKMapPointForCoordinate(view.annotation!.coordinate);
            if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
                continue;
            }
            
            view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.4, options: UIViewAnimationOptions(), animations:{() in
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: {(Bool) in
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            if annotation.isKind(of: MKUserLocation.self) {
                return
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.isKind(of: PokeAnnotationView.self) {
            if let pokeModel = (view as? PokeAnnotationView)?.pokeModel {
                let targetVC = PokeInfoVC(withPokeModel: pokeModel, pokeDetailType: .map)
                self.present(targetVC, animated: true, completion: nil)
            }
        }
    }
}

extension MKCoordinateRegion {
    func distanceMax() -> CLLocationDistance {
        let furthest = CLLocation(latitude: center.latitude + (span.latitudeDelta/2),
                                  longitude: center.longitude + (span.longitudeDelta/2))
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return centerLoc.distance(from: furthest) / 1000.0
    }
}
