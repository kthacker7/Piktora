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

struct AmazonCategory {
    let name : AMZCategoryName
    let nodeID : AMZBrowseNode
}

struct AmazonSubcategory {
    let name : String
    let nodeID : String
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if indexPath.row < self.supportedCategories.count {
            let categoryName = self.supportedCategories[indexPath.row].name
            cell.textLabel?.text = categoryName.rawValue
            cell.textLabel?.font = UIFont(name: "Helvetica", size: 14.0)
        }
        return cell
    }
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ProductSelection", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AmazonCategorySelectionViewController") as? AmazonCategorySelectionViewController {
            vc.isSecondLevel = true
            if indexPath.row < self.supportedCategories.count {
                vc.chosenName = self.supportedCategories[indexPath.row].name
                vc.chosenID = self.supportedCategories[indexPath.row].nodeID
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: Helper Methods
    
    func loadSubCategoryList() {
        if self.chosenID != nil {
            let connector = PiktoraConnector()
            connector.browseNodeLookupForNodeID(nodeID: self.chosenID!.rawValue, success: {_ in
                
            }, failure: { (error) in
                
            })
        }
    }
}
