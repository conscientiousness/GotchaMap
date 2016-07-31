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
    
    let viewFrame = CGRectMake(0, 0, 44, 44)
    var pokeModel: Pokemon?
    
    private lazy var imageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.contentMode = .ScaleAspectFit
        _imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        return _imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf_cancelDownloadTask()
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?){
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        addSubview(imageView)
    }
    
    required override init(frame: CGRect) {
        super.init(frame: viewFrame)
        setUpCalloutView()
        setUpSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK - Private Method
    
    private func setUpCalloutView() {
        canShowCallout = true
        
        let infoBtn = UIButton(frame: CGRectMake(0, 0, 22, 22))
        infoBtn.setImage(UIImage(named: "btn_map_poke_info"), forState: .Normal)
        infoBtn.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleRightMargin]
        rightCalloutAccessoryView = infoBtn
    }
    
    private func setUpSubViews() {
        imageView.frame = bounds
    }
    
    // MARK - Public Method
    
    func setUpAnView(poke: Pokemon) {
        pokeModel = poke
        
        if let imgURL = poke.imgURL {
            imageView.kf_setImageWithURL(imgURL)
        }
    }
}
