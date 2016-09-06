//
//  MapLoadingView.swift
//  gotchamap
//
//  Created by Jesselin on 2016/9/7.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit

class MapLoadingView: UIView {
    
    lazy var indicator: UIActivityIndicatorView = {
        let _indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        _indicator.startAnimating()
        return _indicator
    }()
    
    lazy var title: UILabel = {
        let _title = UILabel()
        _title.numberOfLines = 1
        _title.font = UIFont.mapLoadingTitle()
        _title.textColor = UIColor.whiteColor()
        _title.text = "讀取中"
        return _title
    }()
    
    init() {
        super.init(frame: CGRectZero)
        setupSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubViews() {
        self.cornerRadius = 3.0
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.55)
        
        addSubview(indicator)
        addSubview(title)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["indicator": indicator, "title": title]
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[indicator]-8-[title]-15-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[indicator]-5-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[title]-5-|", options: [], metrics: nil, views: views))
    }
    
    func hide() {
        UIView.animateWithDuration(0.6, animations: {
            self.alpha = 0
            }, completion: { finished in
                if finished {
                    self.hidden = true
                    self.indicator.stopAnimating()
                }
        })
    }
    
    func show() {
        UIView.animateWithDuration(0.6, animations: {
            self.indicator.startAnimating()
            self.hidden = false
            self.alpha = 1
        })
    }
}
