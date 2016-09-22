//
//  CustomOverlayView.swift
//  Camera Test
//
//  Created by Kunal Thacker on 10/09/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit

protocol CustomOverlayDelegate{
    func didCancel(overlayView:CustomOverlayView)
    func didShoot(overlayView:CustomOverlayView)
    func didChangeToGallery(overlayView:CustomOverlayView)
    func switchCamera(overlayView:CustomOverlayView)
    func switchFlashMode(overlayView:CustomOverlayView)
}

class CustomOverlayView: UIView {

    var delegate :CustomOverlayDelegate? = nil
    
    @IBOutlet var flashTextLabel: UILabel!
    
    @IBAction func didPressCancel(_ sender: UIButton) {
        if delegate != nil {
            delegate?.didCancel(overlayView: self)
        }
    }

    @IBAction func didShoot(_ sender: UIButton) {
        if delegate != nil {
            delegate?.didShoot(overlayView: self)
        }
    }

    @IBAction func didChangeToGallery(_ sender: UIButton) {
        if delegate != nil {
            delegate?.didChangeToGallery(overlayView: self)
        }
    }

    @IBAction func switchCamera(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.switchCamera(overlayView: self)
        }
    }
    @IBAction func switchFlash(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.switchFlashMode(overlayView: self)
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
