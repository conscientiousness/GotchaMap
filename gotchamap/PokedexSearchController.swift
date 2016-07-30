//
//  PokedexSearchController.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/24.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit

protocol PokedexSearchDelegate {
    func didStartSearching()
    func didTapOnSearchButton()
    func didChangeSearchText(searchText: String)
}

// Optional Protocol

extension PokedexSearchDelegate {
    func didStartSearching() {
    }
    
    func didTapOnSearchButton() {
    }
}


class PokedexSearchController: UISearchController, UISearchBarDelegate {
    
    var pokedexSearchBar: PokedexSearchBar!
    var pokedexSearchDelegate: PokedexSearchDelegate!
    
    // MARK: Initialization
    
    init(searchResultsController: UIViewController!, searchBarFrame: CGRect, searchBarFont: UIFont, searchBarTextColor: UIColor, searchBarTintColor: UIColor) {
        super.init(searchResultsController: searchResultsController)
        
        configureSearchBar(searchBarFrame, font: searchBarFont, textColor: searchBarTextColor, bgColor: searchBarTintColor)
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Custom functions
    
    func configureSearchBar(frame: CGRect, font: UIFont, textColor: UIColor, bgColor: UIColor) {
        pokedexSearchBar = PokedexSearchBar(frame: frame, font: font , textColor: textColor)
        
        pokedexSearchBar.barTintColor = bgColor
        pokedexSearchBar.tintColor = textColor
        pokedexSearchBar.showsBookmarkButton = false
        pokedexSearchBar.showsCancelButton = false
        pokedexSearchBar.delegate = self
    }
    
    // MARK: UISearchBarDelegate functions
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        pokedexSearchDelegate.didChangeSearchText(searchText)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        pokedexSearchBar.endEditing(true)
    }
}
