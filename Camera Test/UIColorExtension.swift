//
//  UIColorExtension.swift
//  Camera Test
//
//  Created by Kunal Thacker on 24/09/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation

extension UIColor {

    func rgb() -> (red:Double, green:Double, blue:Double, alpha:Double)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Double(fRed)
            let iGreen = Double(fGreen)
            let iBlue = Double(fBlue)
            let iAlpha = Double(fAlpha)

            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return (red:0.0, green:0.0, blue:0.0, alpha:1.0)
        }
    }
}
