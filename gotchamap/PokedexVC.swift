//
//  PokedexVC.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/24.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit

class PokedexVC: UIViewController {
    
    private lazy var backBtn: UIButton = {
        let _backBtn = UIButton()
        _backBtn.setImage(UIImage(named: "btn_back"), forState: .Normal)
        _backBtn.addTarget(self, action: .backBtnSelector, forControlEvents: .TouchUpInside)
        return _backBtn
    }()
    
    private var gridFlowLayout: UICollectionViewFlowLayout {
        let _grid = UICollectionViewFlowLayout()
        _grid.scrollDirection = .Vertical
        _grid.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 8, right: 15)
        _grid.minimumInteritemSpacing = 0
        _grid.minimumLineSpacing = 20
        
        let numberOfItemsPerRow = 3
        let paddings: CGFloat = (_grid.sectionInset.left + _grid.sectionInset.right) * 2
        let spaces = _grid.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1)
        let contentWidth = UIScreen.mainScreen().bounds.width - paddings - spaces
        let itemWidth = contentWidth / CGFloat(numberOfItemsPerRow)
        let itemHeight = itemWidth + 50
        _grid.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        return _grid
    }
    
    private lazy var collectionView: UICollectionView = {
        let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.gridFlowLayout)
        _collectionView.registerClass(PokedexCell.self, forCellWithReuseIdentifier: NSStringFromClass(PokedexCell.self))
        _collectionView.backgroundColor = UIColor.clearColor()
        _collectionView.dataSource = self
        _collectionView.delegate = self
        return _collectionView
    }()
    
    private lazy var searchController: PokedexSearchController = {
        let _searchController = PokedexSearchController(searchResultsController: self, searchBarFrame: CGRectZero, searchBarFont: UIFont.pokedexSearchText(), searchBarTextColor: UIColor.whiteColor(), searchBarTintColor: Palette.Pokedex.Background)
        _searchController.pokedexSearchBar.placeholder = "Search"
        _searchController.pokedexSearchDelegate = self
        self.addToolBar(_searchController.pokedexSearchBar)
        return _searchController
    }()
    
    private lazy var reportTipLabel: UILabel = {
        let _reportTipLabel = UILabel()
        _reportTipLabel.textAlignment = .Center
        _reportTipLabel.font = UIFont.pokedexReportTipTitle()
        _reportTipLabel.textColor = Palette.Pokedex.Background
        _reportTipLabel.text = "點選回報附近的Pokémon吧！"
        _reportTipLabel.adjustsFontSizeToFitWidth = true
        _reportTipLabel.minimumScaleFactor = 0.5
        _reportTipLabel.numberOfLines = 1
        return _reportTipLabel
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let _blurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        return _blurView
    }()
    
    private var alertTextField: UITextField?
    private var actionToEnable : UIAlertAction?
    private var filteredData: [Pokemon] = PokemonHelper.shared.infos
    private let pokedexType: PokedexType
    
    init(pokedexType: PokedexType) {
        self.pokedexType = pokedexType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let userName = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKey.trainerName)
        if userName == nil && pokedexType == .Report {
            showNameAlert()
        }
    }
    
    private func setUpSubviews() {
        view.backgroundColor = Palette.Pokedex.Background
        
        view.addSubview(collectionView)
        view.addSubview(searchController.pokedexSearchBar)
        view.addSubview(backBtn)
        view.addSubview(blurView)
        blurView.addSubview(reportTipLabel)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        searchController.pokedexSearchBar.translatesAutoresizingMaskIntoConstraints = false
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        reportTipLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["collection": collectionView, "search": searchController.pokedexSearchBar,
                     "backBtn": backBtn, "blurView": blurView, "tip": reportTipLabel]
        
        if pokedexType == .Report {
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[blurView]|", options: [], metrics: nil, views: views))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[blurView(44)]|", options: [], metrics: nil, views: views))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tip]|", options: [], metrics: nil, views: views))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tip]|", options: [], metrics: nil, views: views))
        }
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-25-[search(46)]-5-[collection]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collection]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[backBtn(44)]-10-[search]-35-|", options: [], metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: backBtn, attribute: .CenterY, relatedBy: .Equal, toItem: searchController.pokedexSearchBar, attribute: .CenterY, multiplier: 1.0, constant: 1.0))
    }
    
    private func addToolBar(searchBar: UISearchBar){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = Palette.Pokedex.Background
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: .doneSelector)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: .cancelSelector)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        toolBar.sizeToFit()
        searchBar.inputAccessoryView = toolBar
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - Alert Method
    
    private func showNameAlert() {
        let alertController = UIAlertController(title: "您好", message: "請輸入您的訓練師名稱", preferredStyle: .Alert)
        
        let doneAction = UIAlertAction (title: "確認", style: UIAlertActionStyle.Default) {
            (action) -> Void in
            
            if let username = self.alertTextField?.text {
                NSUserDefaults.standardUserDefaults().setObject(username, forKey: UserDefaultsKey.trainerName)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            self.alertTextField = textField
            textField.addTarget(self, action: .textChangeSelector, forControlEvents: .EditingChanged)
        }
        
        alertController.addAction(doneAction)
        self.actionToEnable = doneAction
        doneAction.enabled = false
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func textChanged(sender:UITextField) {
        self.actionToEnable?.enabled = !(sender.text ?? "").isEmpty
    }
    
    private func showReportAlert(indexPath: NSIndexPath) {
        let pokemon = filteredData[indexPath.row]
        
        let alertController = UIAlertController(title: pokemon.name, message: NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKey.trainerName), preferredStyle: .Alert)
        
        let doneAction = UIAlertAction (title: "回報", style: .Default) { (action) -> Void in
            
            if let request = PokeRequest() {
                request.pokemonId = String(pokemon.pokeId)
                request.trainer = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKey.trainerName) ?? "Trainer"
                request.memo = self.alertTextField?.text ?? ""
                
                let formatter = NSDateFormatter();
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss z";
                request.timestemp = formatter.stringFromDate(NSDate())
                
                FirebaseManager.shared.reportLocation(withRequestModel: request)
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "備註"
            self.alertTextField = textField
        }
        
        alertController.addAction(doneAction)
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Button Action Method
    
    @objc private func backBtnPressed(sender: UIButton) {
        //navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func donePressed(){
        view.endEditing(true)
    }
    
    @objc private func cancelPressed(){
        view.endEditing(true)
    }
}

private extension Selector {
    static let backBtnSelector = #selector(PokedexVC.backBtnPressed(_:))
    static let doneSelector = #selector(PokedexVC.donePressed)
    static let cancelSelector = #selector(PokedexVC.cancelPressed)
    static let textChangeSelector = #selector(PokedexVC.textChanged(_:))
}

// MARK: - UICollectionViwDataSource

extension PokedexVC: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(PokedexCell.self), forIndexPath: indexPath)
        (cell as? PokedexCell)?.configure(withPokemon: filteredData[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension PokedexVC: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        switch pokedexType {
        case .Report:
            showReportAlert(indexPath)
            break
        default:
            let vc = PokeInfoVC(withPokeModel: filteredData[indexPath.row])
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
}

// MARK - PokedexSearchDelegate

extension PokedexVC: PokedexSearchDelegate {
    
    func didChangeSearchText(searchText: String) {
        filteredData = PokemonHelper.shared.infos.filter({ (Pokemon) -> Bool in
            let pokeName: NSString = Pokemon.name
            return (pokeName.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })
        
        if searchText.isEmpty {
            filteredData = PokemonHelper.shared.infos
        }
        
        collectionView.reloadData()
    }
}
