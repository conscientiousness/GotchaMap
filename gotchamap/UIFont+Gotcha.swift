//
//  UIFont+Gotcha.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/22.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import UIKit

extension UIFont {
    
    private enum FontFamily {
        static let Regular = "NotoSans-Regular"
        static let Bold = "NotoSans-Bold"
    }
    
    // MARK: - Private Methods
    
    private class func appRegularFontOfSize(fontSize: CGFloat) -> UIFont {
        return UIFont(name: FontFamily.Regular, size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    private class func appBoldFontOfSize(fontSize: CGFloat) -> UIFont {
        return UIFont(name: FontFamily.Bold, size: fontSize) ?? UIFont.boldSystemFontOfSize(fontSize)
    }
    
    // MARK: - Public Methods
    
    class func fontForSmallBallText() -> UIFont {
        return UIFont.appBoldFontOfSize(17)
    }
    
    class func fontForMediumBallText() -> UIFont {
        return UIFont.appBoldFontOfSize(18)
    }

    class func fontForLargeBallText() -> UIFont {
        return UIFont.appBoldFontOfSize(19)
    }
    
    class func pokedexSearchText() -> UIFont {
        return UIFont.appRegularFontOfSize(14)
    }
    
    class func pokedexCellText() -> UIFont {
        return UIFont.appRegularFontOfSize(15)
    }
    
    class func pokeInfoText() -> UIFont {
        return UIFont.appBoldFontOfSize(14)
    }
    
    class func pokeInfoDescText() -> UIFont {
        return UIFont.appRegularFontOfSize(20)
    }
    
    class func pokeInfoVCTitle() -> UIFont {
        return UIFont.appRegularFontOfSize(22)
    }
    
    class func pokedexReportTipTitle() -> UIFont {
        return UIFont.appBoldFontOfSize(20)
    }
    
    class func pokedexReportTrustTitle() -> UIFont {
        return UIFont.appBoldFontOfSize(22)
    }
    
    class func mapLoadingTitle() -> UIFont {
        return UIFont.appBoldFontOfSize(15)
    }
}
