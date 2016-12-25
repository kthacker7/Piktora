//
//  ImageSelectionViewController.swift
//  Piktora
//
//  Created by Kunal Thacker on 27/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit
import SDWebImage

struct AmazonItemWithDetails {
    var title : String
    var ASIN : String
    var imageURL : String
    var formattedPrice : String
}

class ImageSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FlipkartBuyButtonDelegate {

    var website: PK_Website?
    
    // Flipkart variables
    var feedsUrl = ""
    var feedsResponse: FKM_FeedsResponse?
    var parentVC: ViewController?
    var flipkartInstalled = false
    var categoryName = ""
    
    // Amazon variables
    var amazonCategory : String?
    var amazonProducts : AMZSearchResultResponse?
    
    var itemsLeft : Int = 0
    var similarItemsLeft : Int = 0
    
    

    @IBOutlet var adButton: UIButton!

    var isActivityIndicatorAnimating = false
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    @IBOutlet var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.loadProducts()
        self.setupAd()
    }

    // MARK: Collection view data source

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.website == .FlipKart {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlipkartProductCollectionViewCell", for: indexPath) as! FlipkartProductCollectionViewCell
            cell.delegate = self
            if feedsResponse?.productInfoList?.count != nil && indexPath.row < (feedsResponse?.productInfoList?.count)! {
                if let prodInfo = feedsResponse?.productInfoList?[indexPath.row] {
                    cell.indexPath = indexPath
                    cell.setupUI(prodInfo: prodInfo)
                }
            }
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AmazonProductCollectionViewCell", for: indexPath) as! AmazonProductCollectionViewCell
            if self.amazonProducts != nil && (indexPath.row < self.amazonProducts!.items.count) {
                let item = self.amazonProducts!.items[indexPath.row]
                cell.setupUI(amazonItem: item)
            }
            return cell
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.feedsResponse?.productInfoList?.count
        if count != nil && self.website == PK_Website.FlipKart {
            return count!
        } else if self.website == PK_Website.Amazon && self.amazonProducts != nil {
            return self.amazonProducts!.items.count
        }
        return 0
    }


    // MARK: Collection view delegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if feedsResponse?.productInfoList?.count != nil && indexPath.row < (feedsResponse?.productInfoList?.count)! {
            if let prodInfo = feedsResponse?.productInfoList?[indexPath.row] {
                if prodInfo.productBaseInfoV1?.imageUrls != nil {
                    let url = self.getImageUrl(urls: (prodInfo.productBaseInfoV1?.imageUrls)!)
                    UserDefaults.standard.set(URL(string:url), forKey: "ProductImageURL")
                }
                self.parentVC?.selectedProductInfo = prodInfo
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK : FlipkartBuyButton Delegate

    func buyButtonPressed(indexPath: IndexPath) {
        if indexPath.row < (feedsResponse?.productInfoList?.count)! {
            if let prodInfo = feedsResponse?.productInfoList?[indexPath.row] {
                if let prodUrl = prodInfo.productBaseInfoV1?.productURL {
                    UIApplication.shared.openURL(URL(string: prodUrl)!)
                }
            }
        }
    }

    // MARK: Other
    func setupUI() {
        let nib = UINib(nibName: "FlipkartProductCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "FlipkartProductCollectionViewCell")
        let nib2 = UINib(nibName: "AmazonProductCollectionViewCell", bundle: nil)
        self.collectionView.register(nib2, forCellWithReuseIdentifier: "AmazonProductCollectionViewCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        layout.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.itemSize = CGSize(width: self.view.frame.size.width / 2 , height: self.view.frame.size.height / 2)
        self.collectionView.collectionViewLayout = layout
        if #available(iOS 10.0, *) {
            self.collectionView.prefetchDataSource = self
        }
        self.navigationItem.title = "Try any of these products!"
        self.activityIndicator.isHidden = true
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }
    
    func setupAd() {
        if UIApplication.shared.canOpenURL(URL(string: "flipkart://")!) {
            self.adButton.setImage(#imageLiteral(resourceName: "DOTDBanner"), for: .normal)
            self.flipkartInstalled = true
        } else {
            self.adButton.setImage(#imageLiteral(resourceName: "FlipkartInstallBanner"), for: .normal)
            self.flipkartInstalled = false
        }
    }

    @IBAction func adButtonTapped(_ sender: Any) {
        if flipkartInstalled {
            // Redirect to dotd
            UIApplication.shared.openURL(URL(string: "https://www.flipkart.com/offers/deal-of-the-day?affid=iamdonkun")!)
        } else {
            // Redirect to open ad
            UIApplication.shared.openURL(URL(string: "https://www.flipkart.com/?affid=iamdonkun")!)
        }
    }

    func loadProducts() {
        if self.website == PK_Website.FlipKart {
            self.loadFlipkartProducts()
        } else if self.website == PK_Website.Amazon {
            self.loadAmazonProducts()
        }
    }
    
    func loadFlipkartProducts() {
        let connector = PiktoraConnector.sharedInstance
        self.activityIndicator.isHidden = false
        self.isActivityIndicatorAnimating = true
        self.activityIndicator.startAnimating()
        connector.getProducts(urlString: self.feedsUrl, success: {(feedsResponse) in
            if self.isActivityIndicatorAnimating {
                self.activityIndicator.isHidden = true
                self.isActivityIndicatorAnimating = false
                self.activityIndicator.stopAnimating()
            }
            self.filterFeedsResponse(feedsResponse: feedsResponse)
        }, failure: {(error) in
            if self.isActivityIndicatorAnimating {
                self.activityIndicator.isHidden = true
                self.isActivityIndicatorAnimating = false
                self.activityIndicator.stopAnimating()
            }
            let alert = UIAlertController(title: "Oops, something went wrong", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default , handler: { (_) in
                alert.dismiss(animated: false, completion: nil)
                self.loadProducts()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                alert.dismiss(animated: false, completion: nil)
            }))
            self.present(alert, animated: false, completion: nil)
        })
    }
    
    func loadAmazonProducts() {
        let connector = PiktoraConnector.sharedInstance
        if self.amazonCategory != nil {
            self.showActivityIndicator()
            connector.browseNodeLookupForNodeID(nodeID: self.amazonCategory!.nodeID, responseGroups: "MostGifted%2CMostWishedFor%2CNewReleases%2CTopSellers", success: { (responseObject) in
                let response = AMZSearchResultResponse()
                response.initFromXMLResponse(responseObject: responseObject)
                self.getAmazonImageURLS(response: response)
            }, failure: { (error) in
                self.hideActivityIndicator()
                let alert = UIAlertController(title: "Oops, something went wrong", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default , handler: { (_) in
                    alert.dismiss(animated: false, completion: nil)
                    self.loadAmazonProducts()
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                    alert.dismiss(animated: false, completion: nil)
                }))
                self.present(alert, animated: false, completion: nil)
            })
        }
    }
    
    func getAmazonImageURLS(response: AMZSearchResultResponse) {
        self.itemsLeft = response.itemSet.items.count
        self.showActivityIndicator()
        for item in response.itemSet.items {
            let connector = PiktoraConnector.sharedInstance
            connector.itemLookupForASIN(ASIN: item.ASIN, responseGroups: "Images%2COfferSummary%2CSimilarities", success: {(responseObject) in
                self.hideActivityIndicator()
                if let response = responseObject as? AMZItemLookupResponse {
                    let item = AmazonItemWithDetails(title: item.title, ASIN: item.ASIN, imageURL: response.imageURL)
                    self.amazonItems.append(item)
                    for similarItem in response.similarItems {
                        let itemWithDetails = AmazonItemWithDetails(title: similarItem.title, ASIN: similarItem.ASIN, imageURL: nil)
                        self.amazonItems.append(itemWithDetails)
                    }
                    self.itemsLeft -= 1
                    if self.itemsLeft <= 0 {
                        self.amazonItems.sort(by: { (item1, item2) -> Bool in
                            if item1.imageURL == nil {
                                return false
                            }
                            return true
                        })
                        self.getSimilarItemsImageURL()
                        self.collectionView.reloadData()
                    }
                }
            }, failure: {(error) in
            })
        }
    }
    
    func getSimilarItemsImageURL() {
        var similarItemCount = 0
        for item in self.amazonItems {
            if item.imageURL == nil {
                similarItemCount += 1
            }
        }
        self.similarItemsLeft = similarItemCount
        for item in self.amazonItems {
            if item.imageURL == nil {
                let connector = PiktoraConnector.sharedInstance
                connector.itemLookupForASIN(ASIN: item.ASIN, responseGroups: "Images%2COfferSummary", success: { (responseObject) in
                    if let response = responseObject as? AMZItemLookupResponse {
                        let itemWithImage = AmazonItemWithDetails(title: item.title, ASIN: item.ASIN, imageURL: response.imageURL)
                        self.amazonItems = self.amazonItems.filter({ (itemWithDetails) -> Bool in
                            if itemWithDetails.ASIN == itemWithImage.ASIN {
                                return false
                            }
                            return true
                        })
                        self.amazonItems.append(itemWithImage)
                        self.similarItemsLeft -= 1
                        
                        if self.similarItemsLeft <= 0 {
                            self.collectionView.reloadData()
                        }
                    }
                }, failure: { (_) in
                    
                })
            }
        }
    }
    

    func filterFeedsResponse(feedsResponse: FKM_FeedsResponse) {
        if self.categoryName.lowercased() == "watches" {
            feedsResponse.productInfoList =  feedsResponse.productInfoList?.filter({ (element) -> Bool in
                if element.productBaseInfoV1?.categoryPath != nil && ((element.productBaseInfoV1?.categoryPath?.contains("Wrist "))! || (element.productBaseInfoV1?.categoryPath?.contains("Wall"))!) {
                    return true
                }
                return false
            })
        } else if self.categoryName.lowercased() == "mens_footwear" {
            feedsResponse.productInfoList =  feedsResponse.productInfoList?.filter({ (element) -> Bool in
                if element.productBaseInfoV1?.categoryPath != nil && (element.productBaseInfoV1?.categoryPath?.contains("Accessories"))! {
                    return false
                }
                return false
            })
        }
        self.feedsResponse = feedsResponse
        self.collectionView.reloadData()
    }
    
    func hideActivityIndicator() {
//        self.greyView.isHidden = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func showActivityIndicator() {
//        self.greyView.isHidden = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }

    func backButtonPressed() {
        let _ = self.navigationController?.popViewController(animated: true)
    }

    func getImageUrl(urls : Dictionary<String, String>) -> String {
        if let url = urls["unknown"] {
            return url
        }
        if let url = urls["800x800"] {
            return url
        }
        if let url = urls["400x400"] {
            return url
        }
        if let url = urls["200x200"] {
            return url
        }
        return ""
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

extension ImageSelectionViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if self.website == PK_Website.FlipKart {
            for indexPath in indexPaths {
                if feedsResponse?.productInfoList?.count != nil && indexPath.row < (feedsResponse?.productInfoList?.count)! {
                    if let prodInfo = feedsResponse?.productInfoList?[indexPath.row] {
                        if prodInfo.productBaseInfoV1?.imageUrls != nil {
                            let url = self.getImageUrl(urls: (prodInfo.productBaseInfoV1?.imageUrls)!)
                            if url != "" {
                                let _ = SDWebImageDownloader.shared().downloadImage(with: URL(string: url)!, options: .lowPriority, progress: { (_, _) in
                                    
                                }, completed: { (_, _, _, _) in
                                })
                            }
                        }
                    }
                }
            }
        } else {
            for indexPath in indexPaths {
                if indexPath.row < self.amazonItems.count {
                    if let url = self.amazonItems[indexPath.row].imageURL {
                        NSLog("Prefetching: ", url)
                        if url != "" {
                            let _ = SDWebImageDownloader.shared().downloadImage(with: URL(string: url)!, options: .lowPriority, progress: { (_, _) in
                                
                            }, completed: { (_, _, _, _) in
                                
                            })
                        }
                    }
                }
            }
        }
    }


}
