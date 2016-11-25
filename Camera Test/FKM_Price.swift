//
//  FKM_Price.swift
//  Piktora
//
//  Created by Kunal Thacker on 27/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation
import ObjectMapper

class FKM_Price: Mappable {

    var amount: Double?
    var currency: String?

    required init(map: Map) {
        self.mapping(map: map)
    }

    func mapping(map: Map) {
        amount      <- map["amount"]
        currency    <- map["currency"]
    }

}
