//
//  FKM_ProductInfo.swift
//  Piktora
//
//  Created by Kunal Thacker on 27/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation
import ObjectMapper

class FKM_ProductInfo: Mappable {

    var productBaseInfoV1: FKM_ProductBaseInfo?
    var productShippingInfoV1: FKM_ProductShippingInfo?

    required init(map: Map) {
        self.mapping(map: map)
    }

    func mapping(map: Map) {
        productBaseInfoV1       <- map["productBaseInfoV1"]
        productShippingInfoV1   <- map["productShippingInfoV1"]
    }
}
