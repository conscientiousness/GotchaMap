//
//  PokeAnnotationView.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/22.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import Foundation
import MapKit

class PokeAnnotationView: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?){
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        let imageView = UIImageView(frame: bounds)
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "caca")
        addSubview(imageView)
        
        backgroundColor = UIColor.clearColor()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: CGRectMake(0, 0, 30, 30))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
