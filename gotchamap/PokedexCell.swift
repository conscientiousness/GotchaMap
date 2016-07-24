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

    private(set) lazy var imageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.contentMode = .ScaleAspectFit
        return _imageView
    }()
    
    private(set) lazy var indexLabel: UILabel = {
        let _indexLabel = UILabel()
        _indexLabel.font = UIFont.pokedexCellText()
        _indexLabel.textColor = UIColor.whiteColor()
        _indexLabel.textAlignment = .Center
        return _indexLabel
    }()
    
    private(set) lazy var nameLabel: UILabel = {
        let _nameLabel = UILabel()
        _nameLabel.font = UIFont.pokedexCellText()
        _nameLabel.textColor = UIColor.whiteColor()
        _nameLabel.textAlignment = .Center
        return _nameLabel
    }()
    
    private lazy var bgImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.contentMode = .ScaleAspectFill
        return _imageView
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let _blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
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
        imageView.kf_cancelDownloadTask()
        nameLabel.text = nil
    }
    
    // MARK: - Private Methods
    
    private func setUpAppearance() {
        clipsToBounds = true
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.whiteColor().CGColor
        
        contentView.addSubview(bgImageView)
        contentView.addSubview(blurView)
        blurView.addSubview(indexLabel)
        blurView.addSubview(nameLabel)
        blurView.addSubview(imageView)
        
        bgImageView.frame = contentView.bounds
        bgImageView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        blurView.frame = contentView.bounds
        blurView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["imageView": imageView, "index": indexLabel, "name": nameLabel]
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-3-[index(22)][imageView][name(22)]-3-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[index]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[name]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: - Public Methods
    
    func configure(withPokemon pokemon: Pokemon) {
        if let url = pokemon.imgURL {
            bgImageView.kf_setImageWithURL(url, placeholderImage: nil)
            imageView.kf_setImageWithURL(url, placeholderImage: nil)
        }
        nameLabel.text = pokemon.name
        
        indexLabel.text = String(format: "#%03d", pokemon.pokeId)
    }
}
