//
//  FKM_ProductShippingInfo.swift
//  Piktora
//
//  Created by Kunal Thacker on 27/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation
import ObjectMapper

class FKM_ProductShippingInfo: Mappable {

    var shippingCharges: FKM_Price?
    var estimatedDeliveryTime: String?
    var sellerName: String?
    var sellerAverageRating: Double?
    var sellerNoOfRatings: Int?
    var sellerNoOfReviews: Int?

    required init(map: Map) {
        self.mapping(map: map)
    }

     func mapping(map: Map) {
        shippingCharges         <- map["shippingCharges"]
        estimatedDeliveryTime   <- map["estimatedDeliveryTime"]
        sellerName              <- map["sellerName"]
        sellerAverageRating     <- map["sellerAverageRating"]
        sellerNoOfRatings       <- map["sellerNoOfRatings"]
        sellerNoOfReviews       <- map["sellerNoOfReviews"]
    }
}
