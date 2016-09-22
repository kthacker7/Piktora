//
//  OverlayWithImageView.swift
//  Camera Test
//
//  Created by Kunal Thacker on 10/09/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit

class OverlayWithImageView: UIView {
    
    @IBOutlet var backgroundImageView: UIImageView!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundImageView = UIImageView.init()
    }

}
