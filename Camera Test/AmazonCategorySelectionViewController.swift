//
//  AmazonCategorySelectionViewController.swift
//  Piktora
//
//  Created by Kunal Thacker on 19/11/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit

enum AMZCategoryName : String {
    case Automotive = "Automotive"
    case ClothingAndAccessories = "Clothing & Accessories"
    case HomeAndKitchen = "Home & Kitchen"
    case Jewellery = "Jewellery"
    case LuggageAndBags = "Luggage & Bags"
    case ShoesAndHandbags = "Shoes & Handbags"
    case Sports = "Sports, Fitness & Outdoors"
    case Watches = "Watches"
}

enum AMZBrowseNode : String {
    case Automotive = "4772061031"
    case ClothingAndAccessories = "1571272031"
    case HomeAndKitchen = "2454176031"
    case Jewellery = "1951049031"
    case LuggageAndBags = "2454170031"
    case ShoesAndHandbags = "1571284031"
    case Sports = "1984444031"
    case Watches = "1350388031"
}

class AmazonCategorySelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let supportedCategories = [AmazonCategory(name: .Automotive, nodeID: .Automotive),
                               AmazonCategory(name: .ClothingAndAccessories, nodeID: .ClothingAndAccessories),
                               AmazonCategory(name: .HomeAndKitchen, nodeID: .HomeAndKitchen),
                               AmazonCategory(name: .Jewellery, nodeID: .Jewellery),
                               AmazonCategory(name: .LuggageAndBags, nodeID: .LuggageAndBags),
                               AmazonCategory(name: .ShoesAndHandbags, nodeID: .ShoesAndHandbags),
                               AmazonCategory(name: .Sports, nodeID: .Sports),
                               AmazonCategory(name: .Watches, nodeID: .Watches)]
    var isSecondLevel = false
    var alternateCategoryList : [AmazonSubcategory]?
    var chosenName : AMZCategoryName?
    var chosenID : AMZBrowseNode?
    
    var parentVC : ViewController?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var greyView: UIView!
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.isSecondLevel && self.chosenID != nil {
            self.navigationItem.title = self.chosenName?.rawValue
            self.loadSubCategoryList()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.isSecondLevel {
            return supportedCategories.count
        }
        if self.alternateCategoryList != nil {
            return self.alternateCategoryList!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryNameCell", for: indexPath)
        var cellText = ""
        if !self.isSecondLevel {
            if indexPath.row < self.supportedCategories.count {
                let categoryName = self.supportedCategories[indexPath.row].name
                cellText = categoryName.rawValue
            }
        } else {
            if self.alternateCategoryList != nil && indexPath.row < self.alternateCategoryList!.count {
                let categoryName = self.alternateCategoryList![indexPath.row].name
                cellText = categoryName
            }
        }
        cell.textLabel?.text = cellText
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 14.0)
        return cell
    }
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.isSecondLevel {
            let storyboard = UIStoryboard(name: "ProductSelection", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "AmazonCategorySelectionViewController") as? AmazonCategorySelectionViewController {
                vc.isSecondLevel = true
                if indexPath.row < self.supportedCategories.count {
                    vc.chosenName = self.supportedCategories[indexPath.row].name
                    vc.chosenID = self.supportedCategories[indexPath.row].nodeID
                }
                vc.parentVC = self.parentVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if self.alternateCategoryList != nil && indexPath.row < self.alternateCategoryList!.count {
                let storyboard = UIStoryboard(name: "ProductSelection", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ImageSelectionViewController") as! ImageSelectionViewController
                vc.website = .Amazon
//                vc.amazonCategory = self.alternateCategoryList![indexPath.row]
                vc.parentVC = self.parentVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: Helper Methods
    
    func setupUI() {
        self.activityIndicator.center = self.view.center
        self.hideActivityIndicator()
        self.view.addSubview(activityIndicator)
    }
    
    func hideActivityIndicator() {
        self.greyView.isHidden = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func showActivityIndicator() {
        self.greyView.isHidden = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func loadSubCategoryList() {
        if self.chosenID != nil {
            let connector = PiktoraConnector.sharedInstance
            self.showActivityIndicator()
            connector.browseNodeLookupForNodeID(nodeID: self.chosenID!.rawValue, responseGroups: "BrowseNodeInfo", success: { responseObject in
                self.hideActivityIndicator()
                if let response = responseObject as? AMZBrowseNodeResponse {
                    self.alternateCategoryList = response.nodes
                }
                self.tableView.reloadData()
            }, failure: { (error) in
                self.hideActivityIndicator()
                let alert = UIAlertController(title: "Oops, something went wrong", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default , handler: { (_) in
                    alert.dismiss(animated: false, completion: nil)
                    self.loadSubCategoryList()
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                    alert.dismiss(animated: false, completion: nil)
                }))
                self.present(alert, animated: false, completion: nil)
            })
        }
    }
}
