//
//  FKM_FeedsResponse.swift
//  Piktora
//
//  Created by Kunal Thacker on 27/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation
import ObjectMapper

class FKM_FeedsResponse: Mappable {

    var nextURL: String?
    var validTill: CLong?
    var productInfoList: [FKM_ProductInfo]?
    var lastProductID: String?

    required init(map: Map) {
        self.mapping(map: map)
    }

    func mapping(map: Map) {
        nextURL                     <- map["nextUrl"]
        validTill                   <- map["validTill"]
        productInfoList             <- map["productInfoList"]
        lastProductID               <- map["lastProductId"]

    }

}
