//
//  PokeAnnotationView.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/22.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import Foundation
import MapKit
import Kingfisher

let kPokeAnnotationViewId = "pokeAnnotationView"

class PokeAnnotationView: MKAnnotationView {
    
    let viewFrame = CGRect(x: 0, y: 0, width: 44, height: 44)
    var pokeModel: Pokemon?
    
    fileprivate lazy var imageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.contentMode = .scaleAspectFit
        _imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return _imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = viewFrame
        layoutIfNeeded()
        
        addSubview(imageView)
        setUpCalloutView()
        setUpSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK - Private Method
    
    fileprivate func setUpCalloutView() {
        canShowCallout = true
        
        let infoBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        infoBtn.setImage(UIImage(named: "btn_map_poke_info"), for: UIControlState())
        infoBtn.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleRightMargin]
        //rightCalloutAccessoryView = infoBtn
    }
    
    fileprivate func setUpSubViews() {
        imageView.frame = bounds
    }
    
    // MARK - Public Method
    
    func setUpAnView(_ poke: Pokemon) {
        pokeModel = poke
        
        if let imgURL = poke.imgURL {
            imageView.kf.setImage(with: imgURL)
        }
    }
}
