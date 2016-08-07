//
//  PokeInfoVC.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/25.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftyJSON

class PokeInfoVC: UIViewController {

    @IBOutlet weak var pokeNameTitleLabel: UILabel!
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
    @IBOutlet weak var reportInfoView: UIView!
    @IBOutlet weak var reportTrustDegreeLabel: UILabel!
    @IBOutlet weak var reportGoodBtn: UIButton!
    @IBOutlet weak var reportShitBtn: UIButton!
    @IBOutlet weak var reportLoadingView: UIActivityIndicatorView!
    
    private lazy var blurView: UIVisualEffectView = {
        let _blurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        return _blurView
    }()
    
    let pokeModel: Pokemon
    let pokeDetailType: PokeDetailType
    var FIRPokeModel: FIRPokemon?
    
    // MARK: - initializtion
    
    init(withPokeModel pokeModel: Pokemon, pokeDetailType: PokeDetailType) {
        self.pokeModel = pokeModel
        self.pokeDetailType = pokeDetailType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Method
    
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK - Set Up
    
    private func setUpSubViews() {
        // VC
        view.backgroundColor = Palette.PokeInfo.Background
        container.backgroundColor = Palette.PokeInfo.Background
        
        /*/ Navigation
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = Palette.PokeInfo.Background
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.pokeInfoVCTitle()]*/
        
        pokeNameTitleLabel.textColor = UIColor.whiteColor()
        pokeNameTitleLabel.font = UIFont.pokeInfoVCTitle()
        
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
        
        // Report View
        reportInfoView.hidden = true
        reportInfoView.backgroundColor = UIColor.clearColor()
        reportInfoView.cornerRadius = 10

        reportInfoView.insertSubview(blurView, belowSubview: reportTrustDegreeLabel)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[blurView]|", options: [], metrics: nil, views: ["blurView": blurView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[blurView]|", options: [], metrics: nil, views: ["blurView": blurView]))
        
        reportTrustDegreeLabel.font = UIFont.pokedexReportTrustTitle()
        reportTrustDegreeLabel.textColor = UIColor.whiteColor()
        reportTrustDegreeLabel.text = "正確度：??%"
        
        let goodBtnImage = UIImage(named: "btn_good")?.imageWithRenderingMode(.AlwaysTemplate)
        let shitBtnImage = UIImage(named: "btn_shit")?.imageWithRenderingMode(.AlwaysTemplate)
        
        reportGoodBtn.setImage(goodBtnImage, forState: .Normal)
        reportGoodBtn.tintColor = UIColor.blackColor()
        reportGoodBtn.backgroundColor = UIColor.clearColor()
        reportGoodBtn.addTarget(self, action: .goodBtnSelector, forControlEvents: .TouchUpInside)
        
        reportShitBtn.setImage(shitBtnImage, forState: .Normal)
        reportShitBtn.tintColor = UIColor.blackColor()
        reportShitBtn.backgroundColor = UIColor.clearColor()
        reportShitBtn.addTarget(self, action: .shitBtnSelector, forControlEvents: .TouchUpInside)
    }
    
    private func setUpData() {
        title = pokeModel.name
        pokeNameTitleLabel.text = pokeModel.name
        pokeImg.kf_setImageWithURL(pokeModel.imgURL, placeholderImage: nil)
        heightDescLabel.text = pokeModel.height
        weightDescLabel.text = pokeModel.weight
        typeDescLabel.text =  pokeModel.typeDesc
        weaknessDescLabel.text = pokeModel.weaknessDesc
        
        fetchReportData()
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
    
    // MARK: - NetWorking
    
    private func fetchReportData() {
        
        if let objectId = pokeModel.objectId where pokeDetailType == .Map {
            reportInfoView.hidden = false
            reportLoadingView.startAnimating()
            
            // Fetch Pokemon
            FirebaseManager.shared.postsRef.child(objectId).observeEventType(.Value, withBlock: { [weak self] (snapshot) in
                guard let strongSelf = self else { return }
                strongSelf.reportLoadingView.stopAnimating()
                
                if let value = snapshot.value {
                    let model = FIRPokemon(json: JSON(value))
                    strongSelf.FIRPokeModel = model
                    strongSelf.reportTrustDegreeLabel.text = "正確度：\(PokemonHelper.trustPercent(good: model.goodCount, shit: model.shitCount))%"
                }
                
            }) { [weak self] (error) in
                self?.reportLoadingView.stopAnimating()
            }
            
            // Fetch User
            if let userId = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKey.uid) {
                FirebaseManager.shared.usersRef.child(userId).child(FirebaseRefKey.Users.votes).child(objectId).observeSingleEventOfType(.Value, withBlock: { [weak self] (snapshot) in
                    guard let strongSelf = self else { return }
                    strongSelf.reportLoadingView.stopAnimating()
                    
                    guard (snapshot.value as? NSNull) != nil else {
                        if let value = snapshot.value as? NSNumber, type = PokeDetailReportBtnType(rawValue: value.integerValue) {
                            strongSelf.activeBtn(withType: type)
                        }
                        return
                    }
                    
                }) { [weak self] (error) in
                    self?.reportLoadingView.stopAnimating()
                }
            }
        }
    }
    
    private func reportTrustDegree(withType type: PokeDetailReportBtnType) {
        let isGood = (type == .Good ? true : false)
        
        if let userId = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKey.uid), objectid = pokeModel.objectId, model = FIRPokeModel {
            // update user vote status
            FirebaseManager.shared.currentUsersRef.child(userId).child(FirebaseRefKey.Users.votes).child(objectid).setValue(isGood)
            
            // update pokemon vote count
            FirebaseManager.shared.postsRef.child(objectid).child(FirebaseRefKey.Pokemons.vote).child(FirebaseRefKey.Pokemons.Vote.good).setValue(model.goodCount)
            FirebaseManager.shared.postsRef.child(objectid).child(FirebaseRefKey.Pokemons.vote).child(FirebaseRefKey.Pokemons.Vote.shit).setValue(model.shitCount)
        }
    }
    
    // MARK: - Button Action
    
    private func activeBtn(withType type: PokeDetailReportBtnType) {
        switch type {
        case .Good:
            reportGoodBtn.tintColor = Palette.PokeInfo.goodBtn
        default:
            reportShitBtn.tintColor = Palette.PokeInfo.shitBtn
           
        }
    }
    
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func goodBtnPressed(sender: UIButton) {
        
        guard sender.tintColor == Palette.PokeInfo.goodBtn else {
            sender.tintColor = Palette.PokeInfo.goodBtn

            if let model = FIRPokeModel {
                model.adjustTrustCount(goodVal: 1, shitVal: reportShitBtn.tintColor == UIColor.blackColor() ? 0 : -1)
                reportTrustDegree(withType: .Good)
            }
            
            reportShitBtn.tintColor = UIColor.blackColor()
            
            return
        }
    }
    
    @objc private func shitBtnPressed(sender: UIButton) {
        guard sender.tintColor == Palette.PokeInfo.shitBtn else {
            
            sender.tintColor = Palette.PokeInfo.shitBtn
            
            if let model = FIRPokeModel {
                model.adjustTrustCount(goodVal: reportGoodBtn.tintColor == UIColor.blackColor() ? 0 : -1, shitVal: 1)
                reportTrustDegree(withType: .Shit)
            }
            
            reportGoodBtn.tintColor = UIColor.blackColor()
            
            return
        }
    }
}

private extension Selector {
    static let goodBtnSelector = #selector(PokeInfoVC.goodBtnPressed(_:))
    static let shitBtnSelector = #selector(PokeInfoVC.shitBtnPressed(_:))
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
