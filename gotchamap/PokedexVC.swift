//
//  PokedexVC.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/24.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit

class PokedexVC: UIViewController {
    
    private(set) lazy var backBtn: UIButton = {
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
    
    private(set) lazy var collectionView: UICollectionView = {
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
    
    private var filteredData = PokemonBase.shared.infos
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        collectionView.reloadData()
    }
    
    private func setUpSubviews() {
        view.backgroundColor = Palette.Pokedex.Background
        
        view.addSubview(collectionView)
        view.addSubview(searchController.pokedexSearchBar)
        view.addSubview(backBtn)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        searchController.pokedexSearchBar.translatesAutoresizingMaskIntoConstraints = false
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["collection": collectionView, "search": searchController.pokedexSearchBar,
                     "backBtn": backBtn]
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-25-[search(46)]-5-[collection]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collection]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[backBtn(25)]-10-[search]-35-|", options: [], metrics: nil, views: views))
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
    
    @objc private func backBtnPressed(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
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
        let vc = PokeInfoVC(withPokeModel: filteredData[indexPath.row])
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK - PokedexSearchDelegate

extension PokedexVC: PokedexSearchDelegate {
    
    func didChangeSearchText(searchText: String) {
        filteredData = PokemonBase.shared.infos.filter({ (Pokemon) -> Bool in
            let pokeName: NSString = Pokemon.name
            return (pokeName.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })
        
        if searchText.isEmpty {
            filteredData = PokemonBase.shared.infos
        }
        
        collectionView.reloadData()
    }
}

