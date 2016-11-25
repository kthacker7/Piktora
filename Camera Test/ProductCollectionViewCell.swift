//
//  ProductCollectionViewCell.swift
//  Piktora
//
//  Created by Kunal Thacker on 28/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit
import SDWebImage

protocol FlipkartBuyButtonDelegate {
    func buyButtonPressed(indexPath: IndexPath)
}

class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var productPriceLabel: UILabel!

    var indexPath: IndexPath?
    var delegate: FlipkartBuyButtonDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupUI(prodInfo: FKM_ProductInfo) {
        self.productNameLabel.font = UIFont(name: "Helvetica", size: 13.0)
        self.productPriceLabel.font = UIFont(name: "Helvetica", size: 13.0)
        self.productNameLabel.text = prodInfo.productBaseInfoV1?.title
        let mrp = prodInfo.productBaseInfoV1?.mrp
        let fkPrice = prodInfo.productBaseInfoV1?.flipkartPrice
        let fksPrice = prodInfo.productBaseInfoV1?.flipkartSpecialPrice
        let discount = prodInfo.productBaseInfoV1?.discountPercent
        if discount != nil && discount! > 0.0 {
            let priceLabelTitle = self.getPriceLabel(mrp: mrp, fkPrice: fkPrice, fksPrice: fksPrice, discount: discount!)
            self.productPriceLabel.attributedText = priceLabelTitle
        } else {
            var price = ""
            var currency = ""
            if mrp != nil && mrp?.amount != nil {
                price = String((mrp?.amount)!)
                if mrp?.currency != nil {
                    currency = (mrp?.currency)!
                }
            } else if fkPrice != nil && fkPrice!.amount != nil {
                price = String((fkPrice?.amount)!)
                if fkPrice?.currency != nil {
                    currency = (fkPrice?.currency)!
                }
            } else if fksPrice != nil && fksPrice?.amount != nil {
                price = String((fksPrice?.amount)!)
                if fksPrice?.currency != nil {
                    currency = (fksPrice?.currency)!
                }
            }
            self.productPriceLabel.text = self.getSymbolFromCurrency(currency: currency) + " " + price
        }
        if prodInfo.productBaseInfoV1?.imageUrls != nil {
            let url = self.getImageUrl(urls: (prodInfo.productBaseInfoV1?.imageUrls)!)
            if url != "" {
                self.productImageView.sd_setImage(with: URL(string: url)!)
            }
        }
    }

    func getPriceLabel(mrp: FKM_Price?, fkPrice: FKM_Price?, fksPrice: FKM_Price?, discount: Double) -> NSAttributedString {
        var currencySymbol = ""
        var string1 = ""
        var string2 = ""

        if fksPrice != nil && fksPrice?.amount != nil {
            string1 = (String((fksPrice?.amount)!))
            if fksPrice?.currency != nil {
                currencySymbol = self.getSymbolFromCurrency(currency: (fksPrice?.currency)!)
            }
        } else if fkPrice != nil && fkPrice?.amount != nil {
            string1 = (String((fkPrice?.amount)!))
            if fkPrice?.currency != nil {
                currencySymbol = self.getSymbolFromCurrency(currency: (fkPrice?.currency)!)
            }
        }
        if mrp != nil && mrp?.amount != nil {
            string2 = (String((mrp?.amount)!))
            if mrp?.currency != nil {
                currencySymbol = self.getSymbolFromCurrency(currency: (mrp?.currency)!)
            }
        }

        let string3 = "(-" + String(discount) + "%)"

        let labelAttributedText = NSMutableAttributedString(string: currencySymbol + " " + string1 + " " + string2 + " " + string3)

        let range1 = (labelAttributedText.string as NSString).range(of: string1)
        let range2 = (labelAttributedText.string as NSString).range(of: string2)
        let range3 = (labelAttributedText.string as NSString).range(of: string3)

        if range1.location != NSNotFound {
            labelAttributedText.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 14.0) , range: range1)
        }
        if range2.location != NSNotFound {
            labelAttributedText.addAttribute(NSStrikethroughStyleAttributeName, value:  NSUnderlineStyle.styleSingle.rawValue, range: range2)
        }
        if range3.location != NSNotFound {
            labelAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: range3)
        }


        return labelAttributedText

    }

    func getSymbolFromCurrency(currency: String) -> String {
        if currency == "USD" {
            return "$"
        } else {
            return "₹"
        }
    }

    func getImageUrl(urls : Dictionary<String, String>) -> String {
        if let url = urls["400x400"] {
            return url
        }
        if let url = urls["800x800"] {
            return url
        }
        if let url = urls["unknown"] {
            return url
        }
        if let url = urls["200x200"] {
            return url
        }
        return ""
    }

    @IBAction func buyButtonPressed(_ sender: Any) {
        if indexPath != nil {
            delegate?.buyButtonPressed(indexPath: indexPath!)
        }
    }
}
