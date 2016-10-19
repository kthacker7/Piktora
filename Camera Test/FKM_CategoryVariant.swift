//
//  FKM_CategoryVariant.swift
//  Piktora
//
//  Created by Kunal Thacker on 19/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation
import ObjectMapper

class FKM_CategoryVariant : Mappable {

    var resourceName: String?
    var put: String?
    var delete: String?
    var post: String?
    var get: String?
    var deltaGet: String?
    var top: String?

    required init(map: Map) {
        self.mapping(map: map)
    }

    func mapping(map: Map) {
        resourceName    <- map["resourceName"]
        put             <- map["put"]
        delete          <- map["delete"]
        post            <- map["post"]
        get             <- map["get"]
        deltaGet        <- map["deltaGet"]
        top             <- map["top"]
    }

    func getCategoryID() -> String? {
        if get != nil {
            let url = URL(string: get!)
            return url?.lastPathComponent
        }
        return nil
    }
}
