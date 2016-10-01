//
//  UIColor+Gotcha.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/22.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit

enum Palette {
    fileprivate static let GreyishBlack = UIColor(hexString: "#5E5E5E")
    fileprivate static let DarkBlue = UIColor(hexString: "#00103B")
    fileprivate static let YellowishGreen = UIColor(hexString: "#DDFF00")
    fileprivate static let ButterYellow = UIColor(hexString: "#FFD846")
    fileprivate static let AzureBule = UIColor(hexString: "#46F3FF")
    
    enum Map {
        static let Ball = GreyishBlack
    }
    
    enum Pokedex {
        static let Background = DarkBlue
    }
    
    enum PokeInfo {
        static let Background = DarkBlue
        static let infoTitleText = UIColor.white
        static let infoDescText = YellowishGreen
        static let goodBtn = ButterYellow
        static let shitBtn = AzureBule
    }
}
