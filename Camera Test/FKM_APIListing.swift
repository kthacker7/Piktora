//
//  FKM_APIListing.swift
//  Piktora
//
//  Created by Kunal Thacker on 19/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation
import ObjectMapper

class FKM_APIListing : Mappable {

    var availableVariants : Dictionary<String, FKM_CategoryVariant>?
    var apiName : String?

    required init(map : Map) {
        self.mapping(map: map)
    }

    func mapping(map: Map) {
        availableVariants   <- map["availableVariants"]
        apiName             <- map["apiName"]
    }

}
