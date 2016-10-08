//
//  UIImageExtension.swift
//  Camera Test
//
//  Created by Kunal Thacker on 24/09/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation


extension UIImage {

    func getPixelColor(pos: CGPoint) -> UIColor {

        if let pixelData = self.cgImage?.dataProvider?.data {
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

            let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

            let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

            return UIColor(red: r, green: g, blue: b, alpha: a)
        }

        return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }

    func getAverageOfCorners() -> (red:Double, green: Double, blue: Double, alpha: Double, tolerance: Double) {

        let height = self.size.height
        let width = self.size.width

        let c1 = self.getPixelColor(pos: CGPoint.init(x: 0.0 , y: 0.0))
        let c2 = self.getPixelColor(pos: CGPoint.init(x: 0.0 , y: height-1.0))
        let c3 = self.getPixelColor(pos: CGPoint.init(x: width-1.0 , y: 0.0))
        let c4 = self.getPixelColor(pos: CGPoint.init(x: width-1.0 , y: height-1.0))

        let (r1, g1, b1, a1) = c1.rgb()!
        let (r2, g2, b2, a2) = c2.rgb()!
        let (r3, g3, b3, a3) = c3.rgb()!
        let (r4, g4, b4, a4) = c4.rgb()!

        let avgR = (r1 + r2 + r3 + r4)/4.0
        let avgG = (g1 + g2 + g3 + g4)/4.0
        let avgB = (b1 + b2 + b3 + b4)/4.0
        let avgA = (a1 + a2 + a3 + a4)/4.0

        let tR = maxDifference(source: avgR, p1: r1, p2: r2, p3: r3, p4: r4)
        let tG = maxDifference(source: avgG, p1: g1, p2: g2, p3: g3, p4: g4)
        let tB = maxDifference(source: avgB, p1: b1, p2: b2, p3: b3, p4: b4)
        let tA = maxDifference(source: avgA, p1: a1, p2: a2, p3: a3, p4: a4)

        let t = max (tR, tG, tB, tA) > 35.0 ? max (tR, tG, tB, tA) : 35.0
        return (avgR, avgG, avgB, avgA, t)
    }

    func maxDifference(source:Double, p1:Double, p2:Double, p3:Double, p4:Double) -> Double {
        let d1 = mod(x: source - p1)
        let d2 = mod(x: source - p2)
        let d3 = mod(x: source - p3)
        let d4 = mod(x: source - p4)

        return max(d1,d2,d3,d4)
    }

    func mod(x: Double) -> Double {
        if (x < 0.0) {
            return x * (-1.0)
        }
        return x
    }
    
}
