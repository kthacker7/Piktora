//
//  AmazonProductCollectionViewCell.swift
//  Piktora
//
//  Created by Kunal Thacker on 12/16/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit

protocol AmazonBuyButtonDelegate {
    func amazonBuyButtonPressed(indexPath: IndexPath)
}

class AmazonProductCollectionViewCell: UICollectionViewCell {

    // Storyboard connections
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    
    // Delegate and indexpath
    
    var indexPath : IndexPath?
    var delegate : AmazonBuyButtonDelegate?
    
    
    @IBAction func buyButtonTapped(_ sender: Any) {
        if self.indexPath != nil {
            self.delegate?.amazonBuyButtonPressed(indexPath: self.indexPath!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setupUI(amazonItem : AmazonItemWithDetails) {
        self.productTitleLabel.text = amazonItem.title
        self.productPriceLabel.text = amazonItem.formattedPrice
        if amazonItem.imageURL != "" {
            if let url = URL(string : amazonItem.imageURL) {
                self.productImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "ImageSelectionPlaceholder"))
            }
        } else {
            self.productImageView.image = #imageLiteral(resourceName: "ImageSelectionPlaceholder")
        }
    }
}
