//
//  FKM_Affiliate.swift
//  Piktora
//
//  Created by Kunal Thacker on 19/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation
import ObjectMapper

class FKM_Affiliate : Mappable {

    var name: String?
    var apiListings: Dictionary<String, FKM_APIListing>?

    required init(map: Map) {
        self.mapping(map: map)
    }

    func mapping(map: Map) {
        name        <- map["name"]
        apiListings <- map["apiListings"]
    }
}
