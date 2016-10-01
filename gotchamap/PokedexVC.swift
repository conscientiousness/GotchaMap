//
//  PokedexVC.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/24.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit

class PokedexVC: UIViewController {
    
    fileprivate lazy var backBtn: UIButton = {
        let _backBtn = UIButton()
        _backBtn.setImage(UIImage(named: "btn_back"), for: UIControlState())
        _backBtn.addTarget(self, action: .backBtnSelector, for: .touchUpInside)
        return _backBtn
    }()
    
    fileprivate var gridFlowLayout: UICollectionViewFlowLayout {
        let _grid = UICollectionViewFlowLayout()
        _grid.scrollDirection = .vertical
        _grid.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 8, right: 15)
        _grid.minimumInteritemSpacing = 0
        _grid.minimumLineSpacing = 20
        
        let numberOfItemsPerRow = 3
        let paddings: CGFloat = (_grid.sectionInset.left + _grid.sectionInset.right) * 2
        let spaces = _grid.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1)
        let contentWidth = UIScreen.main.bounds.width - paddings - spaces
        let itemWidth = contentWidth / CGFloat(numberOfItemsPerRow)
        let itemHeight = itemWidth + 50
        _grid.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        return _grid
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.gridFlowLayout)
        _collectionView.register(PokedexCell.self, forCellWithReuseIdentifier: NSStringFromClass(PokedexCell.self))
        _collectionView.backgroundColor = UIColor.clear
        _collectionView.dataSource = self
        _collectionView.delegate = self
        return _collectionView
    }()
    
    fileprivate lazy var searchController: PokedexSearchController = {
        let _searchController = PokedexSearchController(searchResultsController: self, searchBarFrame: CGRect.zero, searchBarFont: UIFont.pokedexSearchText(), searchBarTextColor: UIColor.white, searchBarTintColor: Palette.Pokedex.Background!)
        _searchController.pokedexSearchBar.placeholder = "Search"
        _searchController.pokedexSearchDelegate = self
        self.addToolBar(_searchController.pokedexSearchBar)
        return _searchController
    }()
    
    fileprivate lazy var reportTipLabel: UILabel = {
        let _reportTipLabel = UILabel()
        _reportTipLabel.textAlignment = .center
        _reportTipLabel.font = UIFont.pokedexReportTipTitle()
        _reportTipLabel.textColor = Palette.Pokedex.Background
        _reportTipLabel.text = "點選回報附近的Pokémon吧！"
        _reportTipLabel.adjustsFontSizeToFitWidth = true
        _reportTipLabel.minimumScaleFactor = 0.5
        _reportTipLabel.numberOfLines = 1
        return _reportTipLabel
    }()
    
    fileprivate lazy var blurView: UIVisualEffectView = {
        let _blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        return _blurView
    }()
    
    fileprivate var alertTextField: UITextField?
    fileprivate var actionToEnable : UIAlertAction?
    fileprivate var filteredData: [Pokemon] = PokemonHelper.shared.infos
    fileprivate let pokedexType: PokedexType
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userName = UserDefaults.standard.string(forKey: UserDefaultsKey.trainerName)
        if userName == nil && pokedexType == .report {
            showNameAlert()
        }
    }
    
    fileprivate func setUpSubviews() {
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
                     "backBtn": backBtn, "blurView": blurView, "tip": reportTipLabel] as [String : Any]
        
        if pokedexType == .report {
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[blurView]|", options: [], metrics: nil, views: views))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[blurView(44)]|", options: [], metrics: nil, views: views))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tip]|", options: [], metrics: nil, views: views))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tip]|", options: [], metrics: nil, views: views))
        }
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-25-[search(46)]-5-[collection]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collection]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[backBtn(44)]-10-[search]-35-|", options: [], metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: backBtn, attribute: .centerY, relatedBy: .equal, toItem: searchController.pokedexSearchBar, attribute: .centerY, multiplier: 1.0, constant: 1.0))
    }
    
    fileprivate func addToolBar(_ searchBar: UISearchBar){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Palette.Pokedex.Background
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: .doneSelector)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: .cancelSelector)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        searchBar.inputAccessoryView = toolBar
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: - Alert Method
    
    fileprivate func showNameAlert() {
        let alertController = UIAlertController(title: "您好", message: "請輸入您的訓練師名稱", preferredStyle: .alert)
        
        let doneAction = UIAlertAction (title: "確認", style: UIAlertActionStyle.default) {
            (action) -> Void in
            
            if let username = self.alertTextField?.text {
                UserDefaults.standard.set(username, forKey: UserDefaultsKey.trainerName)
                UserDefaults.standard.synchronize()
            }
        }
        
        alertController.addTextField { (textField) -> Void in
            self.alertTextField = textField
            textField.addTarget(self, action: .textChangeSelector, for: .editingChanged)
        }
        
        alertController.addAction(doneAction)
        self.actionToEnable = doneAction
        doneAction.isEnabled = false
        self.present(alertController, animated: true, completion: nil)
    }
    
    func textChanged(_ sender:UITextField) {
        self.actionToEnable?.isEnabled = !(sender.text ?? "").isEmpty
    }
    
    fileprivate func showReportAlert(_ indexPath: IndexPath) {
        let pokemon = filteredData[(indexPath as NSIndexPath).row]
        
        let alertController = UIAlertController(title: pokemon.name, message: UserDefaults.standard.string(forKey: UserDefaultsKey.trainerName), preferredStyle: .alert)
        
        let doneAction = UIAlertAction (title: "回報", style: .default) { (action) -> Void in
            
            if let request = PokeRequest() {
                request.pokemonId = String(pokemon.pokeId)
                request.trainer = UserDefaults.standard.string(forKey: UserDefaultsKey.trainerName) ?? "Trainer"
                request.memo = self.alertTextField?.text ?? ""
                
                let formatter = DateFormatter();
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss z";
                request.timestemp = formatter.string(from: Date())
                
                FirebaseManager.shared.reportLocation(withRequestModel: request)
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "備註"
            self.alertTextField = textField
        }
        
        alertController.addAction(doneAction)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Button Action Method
    
    @objc fileprivate func backBtnPressed(_ sender: UIButton) {
        //navigationController?.popViewControllerAnimated(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func donePressed(){
        view.endEditing(true)
    }
    
    @objc fileprivate func cancelPressed(){
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(PokedexCell.self), for: indexPath)
        (cell as? PokedexCell)?.configure(withPokemon: filteredData[(indexPath as NSIndexPath).row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension PokedexVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch pokedexType {
        case .report:
            showReportAlert(indexPath)
            break
        default:
            let vc = PokeInfoVC(withPokeModel: filteredData[(indexPath as NSIndexPath).row], pokeDetailType: .normal)
            self.present(vc, animated: true, completion: nil)
        }
    }
}

// MARK - PokedexSearchDelegate

extension PokedexVC: PokedexSearchDelegate {
    
    func didChangeSearchText(_ searchText: String) {
        filteredData = PokemonHelper.shared.infos.filter({ (Pokemon) -> Bool in
            let pokeName: NSString = Pokemon.name as NSString
            return (pokeName.range(of: searchText, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        if searchText.isEmpty {
            filteredData = PokemonHelper.shared.infos
        }
        
        collectionView.reloadData()
    }
}
