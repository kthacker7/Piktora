//
//  TutorialViewController.swift
//  Piktora
//
//  Created by Kunal Thacker on 31/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit

protocol PiktoraTutorialDelegate {
    func hideTutorialTapped()
}

class TutorialViewController: UIViewController {
    
    var index : Int!
    @IBOutlet var tutorialImageView: UIImageView!
    @IBOutlet var gotItButton: UIButton!
    var tutorialImage : UIImage?
    var delegate : PiktoraTutorialDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func gotItButtonTapped(_ sender: Any) {
        delegate?.hideTutorialTapped()
    }

    func setupUI() {
        if self.index != 2 {
            self.gotItButton.isHidden = true
        }

        self.tutorialImageView.image = tutorialImage

        self.gotItButton.layer.cornerRadius = 10.0
        self.gotItButton.layer.borderWidth = 1.0
        self.gotItButton.layer.borderColor = UIColor.init(colorLiteralRed: 100.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0).cgColor
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
