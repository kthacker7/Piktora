
//
//  GalleryImageAugmentViewController.swift
//  Camera Test
//
//  Created by Kunal Thacker on 11/09/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit

protocol GalleryImageAugmentDelegate {
    func didCancel(viewController: GalleryImageAugmentViewController)
    func didChoose(viewController: GalleryImageAugmentViewController)
}

class GalleryImageAugmentViewController: UIViewController {

    var selectedImage : UIImage? = nil
    var overLayView : UIImageView? = nil
    var delegate : GalleryImageAugmentDelegate? = nil

    @IBOutlet var selectedImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (selectedImage != nil) {
            self.selectedImageView.image = self.selectedImage
            self.selectedImageView.contentMode = .scaleAspectFit
        }
        if (overLayView != nil) {
            self.overLayView?.isHidden = false
            let image = overLayView?.image
            overLayView?.center = self.view.center
            overLayView?.image = image
            self.view.addSubview(self.overLayView!)
            //self.view.bringSubview(toFront: self.overLayView!)
        }
    }

    @IBAction func didPressCancel(_ sender: AnyObject) {
        if self.delegate != nil {
            delegate?.didCancel(viewController: self)
        }
    }

    @IBAction func didPressChoose(_ sender: AnyObject) {
        if self.delegate != nil {
            delegate?.didChoose(viewController: self)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
