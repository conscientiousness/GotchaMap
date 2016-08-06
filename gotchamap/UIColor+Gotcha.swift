//
//  UIColor+Gotcha.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/22.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit

enum Palette {
    private static let GreyishBlack = UIColor.hex("#5E5E5E")
    private static let DarkBlue = UIColor.hex("#00103B")
    private static let YellowishGreen = UIColor.hex("#DDFF00")
    private static let ButterYellow = UIColor.hex("#FFD846")
    private static let AzureBule = UIColor.hex("#46F3FF")
    
    enum Map {
        static let Ball = GreyishBlack
    }
    
    enum Pokedex {
        static let Background = DarkBlue
    }
    
    enum PokeInfo {
        static let Background = DarkBlue
        static let infoTitleText = UIColor.whiteColor()
        static let infoDescText = YellowishGreen
        static let goodBtn = ButterYellow
        static let shitBtn = AzureBule
    }
}