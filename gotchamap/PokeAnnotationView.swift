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

class PokeAnnotationView: MKAnnotationView {
    
    let viewFrame = CGRectMake(0, 0, 44, 44)
    
    private(set) lazy var imageView: UIImageView = {
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
        setUpSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpSubViews() {
        imageView.frame = bounds
    }
    
    func setUpAnView(poke: Pokemon) {
        if let imgURL = poke.imgURL {
            imageView.kf_setImageWithURL(imgURL)
        }
    }
}
