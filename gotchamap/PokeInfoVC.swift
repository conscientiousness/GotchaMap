//
//  PokeInfoVC.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/25.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit
import Kingfisher

class PokeInfoVC: UIViewController {

    @IBOutlet weak var heightTitleLabel: UILabel!
    @IBOutlet weak var weightTitleLabel: UILabel!
    @IBOutlet weak var typeTitleLabel: UILabel!
    @IBOutlet weak var weaknessTitleLabel: UILabel!
    @IBOutlet weak var heightDescLabel: UILabel!
    @IBOutlet weak var weightDescLabel: UILabel!
    @IBOutlet weak var typeDescLabel: UILabel!
    @IBOutlet weak var weaknessDescLabel: UILabel!
    @IBOutlet weak var pokeImg: UIImageView!
    @IBOutlet weak var pokeBgImg: UIImageView!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var container: UIView!
    
    var pokeData: Pokemon?
    
    /*
    private lazy var blurView: UIVisualEffectView = {
        let _blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        return _blurView
    }()*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        setUpSubViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setUpSubViews() {
        // VC
        view.backgroundColor = Palette.PokeInfo.Background
        container.backgroundColor = Palette.PokeInfo.Background
        
        // Navigation
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = Palette.PokeInfo.Background
        title = "妙挖種子種子"
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.pokeInfoVCTitle()]
        
        // infoLabel
        heightTitleLabel.infoTitleStyle()
        weightTitleLabel.infoTitleStyle()
        typeTitleLabel.infoTitleStyle()
        weaknessTitleLabel.infoTitleStyle()
        heightDescLabel.infoDescStyle()
        weightDescLabel.infoDescStyle()
        typeDescLabel.infoDescStyle()
        weaknessDescLabel.infoDescStyle()
        
        // infoView
        infoContainerView.backgroundColor = UIColor.clearColor()
        infoContainerView.borderColor = UIColor.whiteColor()
        infoContainerView.borderWidth = 1.0
        
        // imageView
        pokeImg.contentMode = .ScaleAspectFit
        pokeImg.clipsToBounds = true
        pokeBgImg.contentMode = .ScaleAspectFill
        if let pokeData = pokeData {
            pokeImg.kf_setImageWithURL(pokeData.imgURL, placeholderImage: nil)
            //pokeBgImg.kf_setImageWithURL(pokeData.imgURL, placeholderImage: nil)
        }
        
        /*/ blurView
        pokeBgImg.insertSubview(blurView, belowSubview: infoContainerView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["blurView": blurView]
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[blurView]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[blurView]|", options: [], metrics: nil, views: views))*/
    }
    
    func findHairLineInImageViewUnder(view view: UIView) -> UIImageView? {
        if let hairLineView = view as? UIImageView where hairLineView.bounds.size.height <= 1.0 {
            return hairLineView
        }
        
        if let hairLineView = view.subviews.flatMap({self.findHairLineInImageViewUnder(view: $0)}).first {
            return hairLineView
        }
        
        return nil
    }
}

extension UILabel {
    
    func infoDescStyle() {
        textColor = Palette.PokeInfo.infoDescText
        font = UIFont.pokeInfoDescText()
    }
    
    func infoTitleStyle() {
        textColor = Palette.PokeInfo.infoTitleText
        numberOfLines = 2
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.5
        font = UIFont.pokeInfoText()
    }
}
