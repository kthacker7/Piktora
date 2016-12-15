//
//  AMZResponseClasses.swift
//  Piktora
//
//  Created by Kunal Thacker on 12/14/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation

struct AmazonCategory {
    let name : AMZCategoryName
    let nodeID : AMZBrowseNode
}

struct AmazonSubcategory {
    let name : String
    let nodeID : String
}

struct AmazonItem {
    let title : String
    let ASIN : String
}

struct AmazonItemWithUrl {
    let title : String
    let ASIN : String
    let detailPageURL : String
    let productGroup : String
}

struct AmazonItemSet {
    var items : [AmazonItem]
    var itemsWithURL : [AmazonItemWithUrl]
}
