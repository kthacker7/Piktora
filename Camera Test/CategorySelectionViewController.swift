//
//  CategorySelectionViewController.swift
//  Piktora
//
//  Created by Kunal Thacker on 23/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit

class CategorySelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var apiResponse : FKM_CategoryList?
    var website : PK_Website?
    var parentVC : ViewController?

    var relevantCategories : [FKM_CategoryVariant] = []
    var supportedCategories = ["televisions", "landline_phones", "mens_clothing", "furniture", "bags_wallets_belts", "kids_clothing", "kids_footwear", "mens_footwear", "air_coolers", "watches", "womens_clothing", "luggage_travel", "refrigerator", "wearable_smart_devices", "microwave_ovens", "home_decor_and_festive_needs", "jewellery", "home_furnishing", "womens_footwear"]
    var isActivityIndicatorAnimating = false
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    override func viewDidLoad() {
        super.viewDidLoad()
        let count = self.apiResponse?.apiGroups?.affiliate?.apiListings?.count
        if count == nil || count! == 0 {
            self.tableView.isHidden = true
        } else {
            self.getRelevantCategories(categoryList: self.apiResponse!)
        }

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.navigationItem.title = "Categories"
        self.activityIndicator.isHidden = true
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relevantCategories.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if relevantCategories.count > 0 {
            return 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryNameCell", for: indexPath)
        cell.selectionStyle = .none
        if indexPath.row < self.relevantCategories.count {
            if let categoryAPIName = self.relevantCategories[indexPath.row].resourceName {
                let categoryName = self.getCategoryFromApi(apiName: categoryAPIName)
                cell.textLabel?.text = categoryName
                cell.textLabel?.font = UIFont(name: "Helvetica", size: 14.0)
            }
        }
        return cell
    }

    // MARK: Table View Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.relevantCategories.count {
            let getFeedsURL = self.relevantCategories[indexPath.row].get
            let storyboard = UIStoryboard(name: "ProductSelection", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ImageSelectionViewController") as! ImageSelectionViewController
            vc.website = self.website
            if let categoryName = self.relevantCategories[indexPath.row].resourceName {
                vc.categoryName = categoryName
            }
            if getFeedsURL != nil {
                vc.feedsUrl = getFeedsURL!
            } else {
                if let getFeedsURL = self.relevantCategories[indexPath.row].top {
                    vc.feedsUrl = getFeedsURL
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
            vc.parentVC = self.parentVC
        }
    }


    // MARK: Button Actions

    @IBAction func tryAgainTapped(_ sender: Any) {
        self.loadCategories()
    }

    // MARK: Other

    func loadCategories() {
        let connector = PiktoraConnector()
        self.activityIndicator.isHidden = false
        self.isActivityIndicatorAnimating = true
        self.activityIndicator.startAnimating()
        connector.getCategoryList(endPoint: "api/iamdonkun.json", success: {categoryList in
            if self.isActivityIndicatorAnimating {
                self.activityIndicator.isHidden = true
                self.isActivityIndicatorAnimating = false
                self.activityIndicator.stopAnimating()
            }
            self.apiResponse = categoryList
            let count = self.apiResponse?.apiGroups?.affiliate?.apiListings?.count
            if count == nil || count! == 0 {
                self.tableView.isHidden = true
                if count == 0 {
                    let alert = UIAlertController(title: "Oops!", message: "No categories found. Perhaps the server is down. Please try again later, or choose a product from your gallery!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: false, completion: nil)

                }
            } else {
                self.getRelevantCategories(categoryList: self.apiResponse!)
            }

        }, failure: { error in
            if self.isActivityIndicatorAnimating {
                self.activityIndicator.isHidden = true
                self.isActivityIndicatorAnimating = false
                self.activityIndicator.stopAnimating()
            }
            let alert = UIAlertController(title: "Oops, something went wrong", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default , handler: { (_) in
                alert.dismiss(animated: false, completion: nil)
                self.loadCategories()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                alert.dismiss(animated: false, completion: nil)
            }))
            
        })
    }

    func getRelevantCategories(categoryList: FKM_CategoryList) {
        if let apiGroups = categoryList.apiGroups {
            if let affiliate = apiGroups.affiliate {
                if let apiListings = affiliate.apiListings {
                    for listing in apiListings.values {
                        if let apiName = listing.apiName {
                            if self.supportedCategories.contains(apiName) && listing.availableVariants != nil && listing.availableVariants!["v1.1.0"] != nil {
                                let variant = (listing.availableVariants!)["v1.1.0"]!
                                self.relevantCategories.append(variant)
                            }
                        }
                    }
                }
            }
        }
        self.relevantCategories.sort { (var1, var2) -> Bool in
            if var1.resourceName == nil {
                return true
            }
            if var2.resourceName == nil {
                return false
            }
            let result = var1.resourceName!.compare(var2.resourceName!)
            return result == ComparisonResult.orderedAscending
        }
    }

    func getCategoryFromApi(apiName: String?) ->  String {
        if apiName == nil {
            return ""
        }
        let apiNameCopy = NSString(string: apiName!)
        var categoryName = apiNameCopy.replacingOccurrences(of: "_", with: " ")
        categoryName = categoryName.capitalized
        return categoryName
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
