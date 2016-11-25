//
//  FKM_CategoryList.swift
//  Piktora
//
//  Created by Kunal Thacker on 19/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation
import ObjectMapper

class FKM_CategoryList: Mappable {
    var title: String?
    var description: String?
    var apiGroups: FKM_APIGroup?

    required init(map: Map) {
        self.mapping(map: map)
    }

    func mapping(map: Map) {
        title       <- map["title"]
        description <- map["description"]
        apiGroups   <- map["apiGroups"]
    }
}
