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
    
    fileprivate lazy var blurView: UIVisualEffectView = {
        let _blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK - Set Up
    
    fileprivate func setUpSubViews() {
        // VC
        view.backgroundColor = Palette.PokeInfo.Background
        container.backgroundColor = Palette.PokeInfo.Background
        
        /*/ Navigation
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = Palette.PokeInfo.Background
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.pokeInfoVCTitle()]*/
        
        pokeNameTitleLabel.textColor = UIColor.white
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
        infoContainerView.backgroundColor = UIColor.clear
        infoContainerView.borderColor = UIColor.white
        infoContainerView.borderWidth = 1.0
        
        // imageView
        pokeImg.contentMode = .scaleAspectFit
        pokeImg.clipsToBounds = true
        pokeBgImg.contentMode = .scaleAspectFill
        
        // Report View
        reportInfoView.isHidden = true
        reportInfoView.backgroundColor = UIColor.clear
        reportInfoView.cornerRadius = 10

        reportInfoView.insertSubview(blurView, belowSubview: reportTrustDegreeLabel)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[blurView]|", options: [], metrics: nil, views: ["blurView": blurView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[blurView]|", options: [], metrics: nil, views: ["blurView": blurView]))
        
        reportTrustDegreeLabel.font = UIFont.pokedexReportTrustTitle()
        reportTrustDegreeLabel.textColor = UIColor.white
        reportTrustDegreeLabel.text = "正確度：??%"
        
        let goodBtnImage = UIImage(named: "btn_good")?.withRenderingMode(.alwaysTemplate)
        let shitBtnImage = UIImage(named: "btn_shit")?.withRenderingMode(.alwaysTemplate)
        
        reportGoodBtn.setImage(goodBtnImage, for: UIControlState())
        reportGoodBtn.tintColor = UIColor.black
        reportGoodBtn.backgroundColor = UIColor.clear
        reportGoodBtn.addTarget(self, action: .goodBtnSelector, for: .touchUpInside)
        
        reportShitBtn.setImage(shitBtnImage, for: UIControlState())
        reportShitBtn.tintColor = UIColor.black
        reportShitBtn.backgroundColor = UIColor.clear
        reportShitBtn.addTarget(self, action: .shitBtnSelector, for: .touchUpInside)
    }
    
    fileprivate func setUpData() {
        title = pokeModel.name
        pokeNameTitleLabel.text = pokeModel.name
        pokeImg.kf.setImage(with: pokeModel.imgURL)
        heightDescLabel.text = pokeModel.height
        weightDescLabel.text = pokeModel.weight
        typeDescLabel.text =  pokeModel.typeDesc
        weaknessDescLabel.text = pokeModel.weaknessDesc
        
        fetchReportData()
    }
    
    // for Navigation Bar
    fileprivate func findHairLineInImageViewUnder(view: UIView) -> UIImageView? {
        if let hairLineView = view as? UIImageView , hairLineView.bounds.size.height <= 1.0 {
            return hairLineView
        }
        
        if let hairLineView = view.subviews.flatMap({self.findHairLineInImageViewUnder(view: $0)}).first {
            return hairLineView
        }
        
        return nil
    }
    
    // MARK: - NetWorking
    
    fileprivate func fetchReportData() {
        
        if let objectId = pokeModel.objectId , pokeDetailType == .map {
            reportInfoView.isHidden = false
            reportLoadingView.startAnimating()
            
            // Fetch Pokemon
            FirebaseManager.shared.postsRef.child(objectId).observe(.value, with: { [weak self] (snapshot) in
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
            
            
            // Fetch User Vote
            if let userId = UserDefaults.standard.string(forKey: UserDefaultsKey.uid) {
                Debug.print("\(objectId) , \(userId)")
                FirebaseManager.shared.usersRef.child(userId).child(FirebaseRefKey.Users.votes).child(objectId).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                    guard let strongSelf = self else { return }
                    strongSelf.reportLoadingView.stopAnimating()
                    Debug.print(snapshot.value)
                    guard (snapshot.value as? NSNull) != nil else {
                        if let value = snapshot.value as? NSNumber, let type = PokeDetailReportBtnType(rawValue: value.intValue) {
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
    
    fileprivate func reportTrustDegree(withType type: PokeDetailReportBtnType) {
        let isGood = (type == .good ? true : false)
        
        if let objectid = pokeModel.objectId, let model = FIRPokeModel {
            // update user vote status
            FirebaseManager.shared.currentUsersRef.child(FirebaseRefKey.Users.votes).child(objectid).setValue(isGood)
            
            // update pokemon vote count
            FirebaseManager.shared.postsRef.child(objectid).child(FirebaseRefKey.Pokemons.vote).child(FirebaseRefKey.Pokemons.Vote.good).setValue(model.goodCount)
            FirebaseManager.shared.postsRef.child(objectid).child(FirebaseRefKey.Pokemons.vote).child(FirebaseRefKey.Pokemons.Vote.shit).setValue(model.shitCount)
        }
    }
    
    // MARK: - Button Action
    
    fileprivate func activeBtn(withType type: PokeDetailReportBtnType) {
        switch type {
        case .good:
            reportGoodBtn.tintColor = Palette.PokeInfo.goodBtn
        default:
            reportShitBtn.tintColor = Palette.PokeInfo.shitBtn
           
        }
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func goodBtnPressed(_ sender: UIButton) {
        
        guard sender.tintColor == Palette.PokeInfo.goodBtn else {
            sender.tintColor = Palette.PokeInfo.goodBtn

            if let model = FIRPokeModel {
                model.adjustTrustCount(goodVal: 1, shitVal: reportShitBtn.tintColor == UIColor.black ? 0 : -1)
                reportTrustDegree(withType: .good)
            }
            
            reportShitBtn.tintColor = UIColor.black
            
            return
        }
    }
    
    @objc fileprivate func shitBtnPressed(_ sender: UIButton) {
        guard sender.tintColor == Palette.PokeInfo.shitBtn else {
            
            sender.tintColor = Palette.PokeInfo.shitBtn
            
            if let model = FIRPokeModel {
                model.adjustTrustCount(goodVal: reportGoodBtn.tintColor == UIColor.black ? 0 : -1, shitVal: 1)
                reportTrustDegree(withType: .shit)
            }
            
            reportGoodBtn.tintColor = UIColor.black
            
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
