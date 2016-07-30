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
    
    var pokeModel: Pokemon?
    
    init(withPokeModel pokeModel: Pokemon) {
        self.pokeModel = pokeModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        setUpSubViews()
        setUpData()
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
    }
    
    private func setUpData() {
        title = pokeModel?.name
        pokeImg.kf_setImageWithURL(pokeModel?.imgURL, placeholderImage: nil)
        heightDescLabel.text = pokeModel?.height
        weightDescLabel.text = pokeModel?.weight
        typeDescLabel.text =  pokeModel?.typeDesc
        weaknessDescLabel.text = pokeModel?.weaknessDesc
    }
    
    // for Navigation Bar
    private func findHairLineInImageViewUnder(view view: UIView) -> UIImageView? {
        if let hairLineView = view as? UIImageView where hairLineView.bounds.size.height <= 1.0 {
            return hairLineView
        }
        
        if let hairLineView = view.subviews.flatMap({self.findHairLineInImageViewUnder(view: $0)}).first {
            return hairLineView
        }
        
        return nil
    }
}

private extension UILabel {
    
    func infoDescStyle() {
        textColor = Palette.PokeInfo.infoDescText
        font = UIFont.pokeInfoDescText()
        numberOfLines = 2
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.6
    }
    
    func infoTitleStyle() {
        textColor = Palette.PokeInfo.infoTitleText
        font = UIFont.pokeInfoText()
    }
}
