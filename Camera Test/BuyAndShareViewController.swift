//
//  BuyAndShareViewController.swift
//  Piktora
//
//  Created by Kunal Thacker on 01/11/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit
import MessageUI

class BuyAndShareViewController: UIViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet var productPriceLabel: UILabel!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var buyAndShareView: UIView!
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var shareButton: UIButton!

    @IBOutlet var buyAndShareButtonViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var buyButtonHeightConstraint: NSLayoutConstraint!

    @IBOutlet var overlayedImageView: UIImageView!

    @IBOutlet var productDetailWidthConstraint: NSLayoutConstraint!
    var selectedProdInfo: FKM_ProductInfo?
    var overlayedImage: UIImage?
    var parentVC: ViewController?


    var buyAndShareExpanded = false

    // Rating objects
    @IBOutlet var questionView: UIView!
    @IBOutlet var loveItView: UIView!
    @IBOutlet var feedbackView: UIView!
    @IBOutlet var greyView: UIView!

    @IBOutlet var loveItViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var questionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var feedbackViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.overlayedImageView.image = self.overlayedImage
        self.setupProductUI()
        self.setupBuyAndShareUI()
        self.collapse()
        self.handleRatingRequest()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        if self.buyAndShareExpanded {
            self.buyAndShareExpanded = false
            self.collapse()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
        if self.buyAndShareExpanded {
            self.buyAndShareExpanded = false
            self.collapse()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Button actions

    @IBAction func shareButtonTapped(_ sender: Any) {
        self.shareImage()
    }

    @IBAction func buyButtonTapped(_ sender: Any) {
        self.buyProduct()
    }

    @IBAction func pikItTapped(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func chooseProductTapped(_ sender: Any) {
        if let parentVCUnwrapped = self.parentVC {
            let _ = self.navigationController?.popToViewController(parentVCUnwrapped, animated: true)
        }
    }

    //MARK: Others

    func setupProductUI() {
        if let prodInfo = self.selectedProdInfo {
            self.productDetailWidthConstraint.constant = self.view.bounds.width * 2.0 / 3.0
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

        } else {
            self.productDetailWidthConstraint.constant = 0

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

        let labelAttributedText = NSMutableAttributedString(string: currencySymbol + " " + string1 + " " + string2 + " "  + string3)

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

    func setupBuyAndShareUI() {
        self.buyAndShareView.layer.cornerRadius = 10.0
        self.buyAndShareView.layer.borderWidth = 1.0
        self.buyAndShareView.layer.borderColor = UIColor.init(colorLiteralRed: 100.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0).cgColor

        self.buyButton.layer.borderWidth = 1.0
        self.buyButton.layer.borderColor = UIColor.init(colorLiteralRed: 100.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0).cgColor

        self.shareButton.layer.borderWidth = 1.0
        self.shareButton.layer.borderColor = UIColor.init(colorLiteralRed: 100.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0).cgColor
    }

    func setupReviewUI() {
        self.questionView.layer.cornerRadius = 10.0
        self.questionView.layer.borderWidth = 1.0
        self.questionView.layer.borderColor = UIColor.init(colorLiteralRed: 0.0/255.0, green: 118.0/255.0, blue: 217.0/255.0, alpha: 1.0).cgColor

        self.loveItView.layer.cornerRadius = 10.0
        self.loveItView.layer.borderWidth = 1.0
        self.loveItView.layer.borderColor = UIColor.init(colorLiteralRed: 0.0/255.0, green: 118.0/255.0, blue: 217.0/255.0, alpha: 1.0).cgColor

        self.feedbackView.layer.cornerRadius = 10.0
        self.feedbackView.layer.borderWidth = 1.0
        self.feedbackView.layer.borderColor = UIColor.init(colorLiteralRed: 0.0/255.0, green: 118.0/255.0, blue: 217.0/255.0, alpha: 1.0).cgColor

    }

    func expand() {
        self.buyAndShareView.layoutIfNeeded()
        if self.selectedProdInfo != nil {
            self.buyButtonHeightConstraint.constant = 45
        } else {
            self.buyButtonHeightConstraint.constant = 0
        }
        self.buyAndShareButtonViewHeightConstraint.constant = self.buyButtonHeightConstraint.constant + 45.0
        UIView.animate(withDuration: 0.1, animations: {
            self.buyAndShareView.layoutIfNeeded()
        })
    }

    func collapse() {
        self.buyAndShareView.layoutIfNeeded()
        self.buyButtonHeightConstraint.constant = 0
        self.buyAndShareButtonViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.1, animations: {
            self.buyAndShareView.layoutIfNeeded()
        })
    }

    func expandOrCollapse() {
        if self.buyAndShareExpanded {
            self.buyAndShareExpanded = !self.buyAndShareExpanded
            self.collapse()
        } else {
            self.buyAndShareExpanded = !self.buyAndShareExpanded
            self.expand()
        }

    }

    @IBAction func buyViewButtonTapped(_ sender: Any) {
        self.buyProduct()
    }

    @IBAction func shareViewButtonTapped(_ sender: Any) {
        self.shareImage()
        
    }


    @IBAction func buyAndShareButtonTapped(_ sender: Any) {
        self.expandOrCollapse()
    }

    func shareImage() {
        if let image = self.overlayedImageView.image {
            let activityItems = [image]
            let activityVC = UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.navigationController?.present(activityVC, animated: true, completion:nil)
        } else {
            let vc = UIAlertController.init(title: "Oops!", message: "You haven't clicked or selected an image. You don't want to share a blank image do you? :)", preferredStyle: .alert)
            vc.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in

            }))
            self.present(vc, animated: true, completion: nil)
        }
    }

    func buyProduct() {
        if let prodInfo = self.selectedProdInfo {
            if let prodUrl = prodInfo.productBaseInfoV1?.productURL {
                UIApplication.shared.openURL(URL(string: prodUrl)!)
            }
        }
    }

    // MARK: Handling rating

    func handleRatingRequest() {
        self.questionViewHeightConstraint.constant = 0
        self.loveItViewHeightConstraint.constant = 0
        self.feedbackViewHeightConstraint.constant = 0
        self.view.layoutIfNeeded()

        let userDefaults = UserDefaults.standard
        let lastAsked = userDefaults.integer(forKey: "LastAsked")
        let noThanksSet = userDefaults.string(forKey: "NoThanks")
        let sharedOrReviewed = userDefaults.string(forKey: "SharedOrReviewed")
        if sharedOrReviewed != nil {
            return
        }
        if noThanksSet != nil {
            if ((lastAsked - 5) % 30) == 0 {
                // Ask reviews
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                    self.askReview()
                })
            }
        } else {
            if lastAsked == 5  {
                // Ask reviews
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                    self.askReview()
                })
            }
        }
        userDefaults.set(lastAsked + 1, forKey: "LastAsked")
    }

    func askReview() {
        self.setupReviewUI()
        self.greyView.isHidden = false
        self.view.layoutIfNeeded()
        self.questionViewHeightConstraint.constant = 132
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }

    // MARK: Question actions
    @IBAction func loveItTapped(_ sender: Any) {
        self.view.layoutIfNeeded()
        self.questionViewHeightConstraint.constant = 0
        self.loveItViewHeightConstraint.constant = 176
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }

    @IBAction func needsImprovementTapped(_ sender: Any) {
        self.view.layoutIfNeeded()
        self.questionViewHeightConstraint.constant = 0
        self.feedbackViewHeightConstraint.constant = 132
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }

    // MARK: Love it actions

    @IBAction func shareAppTapped(_ sender: Any) {
        self.loveItViewHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
        self.greyView.isHidden = true
        UserDefaults.standard.set("SharedOrReviewed", forKey: "SharedOrReviewed")
        let textToShare = "Piktora lets you try on stuff before you buy it! Check out this awesome app- "
        if let myWebsite = NSURL(string: "https://itunes.apple.com/in/app/piktora/id1164042277?ls=1&mt=8") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    @IBAction func noThanksTapped(_ sender: Any) {
        self.loveItViewHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
        self.greyView.isHidden = true
        UserDefaults.standard.set("NoThanks", forKey: "NoThanks")
    }
    @IBAction func rateAppTapped(_ sender: Any) {
        self.loveItViewHeightConstraint.constant = 0
        self.greyView.isHidden = true
        self.view.layoutIfNeeded()
        UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/in/app/piktora/id1164042277?ls=1&mt=8")!)
        UserDefaults.standard.set("SharedOrReviewed", forKey: "SharedOrReviewed")
    }

    // MARK: Needs Improvement actions

    @IBAction func feedbackYesTapped(_ sender: Any) {
        self.feedbackViewHeightConstraint.constant = 0
        self.greyView.isHidden = true
        self.view.layoutIfNeeded()
        let vc = MFMailComposeViewController()
        vc.delegate = self
        vc.setToRecipients(["kunalrox@live.com"])
        vc.setSubject("Piktora needs improvement!")
        self.present(vc, animated: true, completion: nil)
        UserDefaults.standard.set("NoThanks", forKey: "NoThanks")
    }

    @IBAction func feedbackNoTapped(_ sender: Any) {
        self.feedbackViewHeightConstraint.constant = 0
        self.greyView.isHidden = true
        self.view.layoutIfNeeded()
        UserDefaults.standard.set("NoThanks", forKey: "NoThanks")
    }

    // MARK: MFMailComposeViewController delegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: {
            if result == .sent {
                let vc = UIAlertController.init(title: "Thank you for your feedback!", message: "We really appreciate your feedback, and it is very valuable to us. We hope your experience improves in the next update of the app :)", preferredStyle: .alert)
                vc.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in

                }))
                self.present(vc, animated: true, completion: nil)
            }
        })
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
