//
//  FKM_ProductBaseInfo.swift
//  Piktora
//
//  Created by Kunal Thacker on 27/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation
import ObjectMapper

class FKM_ProductBaseInfo: Mappable {

    var productId: String?
    var title: String?
    var productDescription: String?
    var imageUrls: Dictionary<String, String>?
    var mrp: FKM_Price?
    var flipkartPrice: FKM_Price?
    var flipkartSpecialPrice: FKM_Price?
    var productURL: String?
    var productBrand: String?
    var inStock: Bool?
    var codAvailable: Bool?
    var discountPercent: Double?
    var offers: [String]?
    var categoryPath: String?
    var attributes: Dictionary<String, String>?


    required init(map: Map) {
        self.mapping(map: map)
    }

    func mapping(map: Map) {
        productId               <- map["productId"]
        title                   <- map["title"]
        productDescription      <- map["productDescription"]
        imageUrls               <- map["imageUrls"]
        mrp                     <- map["maximumRetailPrice"]
        flipkartPrice           <- map["flipkartSellingPrice"]
        flipkartSpecialPrice    <- map["flipkartSpecialPrice"]
        productURL              <- map["productUrl"]
        productBrand            <- map["productBrand"]
        inStock                 <- map["inStock"]
        codAvailable            <- map["codAvailable"]
        discountPercent         <- map["discountPercentage"]
        offers                  <- map["offers"]
        categoryPath            <- map["categoryPath"]
        attributes              <- map["attributes"]
    }

}
