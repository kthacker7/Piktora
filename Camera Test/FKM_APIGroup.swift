//
//  FKM_APIGroup.swift
//  Piktora
//
//  Created by Kunal Thacker on 19/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation
import ObjectMapper

class FKM_APIGroup : Mappable {

    var affiliate: FKM_Affiliate?

    required init(map:Map) {
        self.mapping(map: map)
    }

    func mapping(map: Map) {
        affiliate   <- map["affiliate"]
    }
}
