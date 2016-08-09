//
//  ReportPokeMapVC.swift
//  gotchamap
//
//  Created by Jesselin on 2016/8/8.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit

class ReportPokeMapVC: UIViewController {
    
    private lazy var mapView: MKMapView = {
        let _mapView = MKMapView()
        _mapView.cornerRadius = 10
        _mapView.delegate = self
        _mapView.setUserTrackingMode(.Follow, animated: true)
        return _mapView
    }()
    /*
    private lazy var backHomeBtn: UIButton = {
        let _backHomeBtn = UIButton()
        _backHomeBtn.setImage(UIImage(named: "btn_backHome"), forState: .Normal)
        _backHomeBtn.imageView?.contentMode = .ScaleAspectFit
        _backHomeBtn.backgroundColor = UIColor.clearColor()
        _backHomeBtn.addTarget(self, action: .backHomeBtnSelector, forControlEvents: .TouchUpInside)
        return _backHomeBtn
    }()
    
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
        
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: repotPokeBtn, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)])
    }*/
    
}

// MARK: - MKMapView Delegate

extension ReportPokeMapVC: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){

    }
}
