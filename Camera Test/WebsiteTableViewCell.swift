//
//  WebsiteTableViewCell.swift
//  Piktora
//
//  Created by Kunal Thacker on 23/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit

protocol WebsiteTableViewDelegate {
    func didSelectWebsite(website: PK_Website)
}

class WebsiteTableViewCell: UITableViewCell {

    @IBOutlet var websiteLogoImageView: UIImageView!
    @IBOutlet var separatorView: UIView!
    var indexPath : IndexPath?
    var delegate : WebsiteTableViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WebsiteTableViewCell.imageViewTapped))
        self
            .websiteLogoImageView.addGestureRecognizer(tapGestureRecognizer)
        self.websiteLogoImageView.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func imageViewTapped() {
        if indexPath != nil && delegate != nil {
            var website: PK_Website?
            if indexPath?.row == 0 {
                website = .FlipKart
            } else {
                website = .Gallery
            }
            delegate?.didSelectWebsite(website: website!)
        }
    }
    
}
