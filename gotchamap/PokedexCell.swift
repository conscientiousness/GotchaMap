//
//  PokedexCell.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/24.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit
import Kingfisher

class PokedexCell: UICollectionViewCell {

    fileprivate(set) lazy var imageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.contentMode = .scaleAspectFit
        return _imageView
    }()
    
    fileprivate(set) lazy var indexLabel: UILabel = {
        let _indexLabel = UILabel()
        _indexLabel.font = UIFont.pokedexCellText()
        _indexLabel.textColor = UIColor.white
        _indexLabel.textAlignment = .center
        return _indexLabel
    }()
    
    fileprivate(set) lazy var nameLabel: UILabel = {
        let _nameLabel = UILabel()
        _nameLabel.font = UIFont.pokedexCellText()
        _nameLabel.textColor = UIColor.white
        _nameLabel.textAlignment = .center
        return _nameLabel
    }()
    
    fileprivate lazy var bgImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.contentMode = .scaleAspectFill
        return _imageView
    }()
    
    fileprivate lazy var blurView: UIVisualEffectView = {
        let _blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        return _blurView
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpAppearance()
    }
    
    // MARK: - UICollectionViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        nameLabel.text = nil
    }
    
    // MARK: - Private Methods
    
    fileprivate func setUpAppearance() {
        clipsToBounds = true
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.white.cgColor
        
        contentView.addSubview(bgImageView)
        contentView.addSubview(blurView)
        blurView.addSubview(indexLabel)
        blurView.addSubview(nameLabel)
        blurView.addSubview(imageView)
        
        bgImageView.frame = contentView.bounds
        bgImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        blurView.frame = contentView.bounds
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["imageView": imageView, "index": indexLabel, "name": nameLabel] as [String : Any]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[index(22)][imageView][name(22)]-3-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[index]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[name]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: - Public Methods
    
    func configure(withPokemon pokemon: Pokemon) {
        if let url = pokemon.imgURL {
            bgImageView.kf.setImage(with: url)
            imageView.kf.setImage(with: url)
        }
        nameLabel.text = pokemon.name
        indexLabel.text = String(format: "#%03d", pokemon.pokeId)
    }
}
