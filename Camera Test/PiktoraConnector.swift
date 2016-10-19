//
//  PiktoraConnector.swift
//  Piktora
//
//  Created by Kunal Thacker on 17/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation
import AFNetworking
import ObjectMapper

class PiktoraConnector {

    func get(endPoint: String, success:@escaping (FKM_CategoryList) -> ()) {

        let params = self.getRequestParams()
        let configs = URLSessionConfiguration.default
        configs.httpAdditionalHeaders = params as? [AnyHashable : Any]

        let sessionManager = AFHTTPSessionManager.init(baseURL: nil, sessionConfiguration: configs)

        sessionManager.requestSerializer = AFJSONRequestSerializer()
        sessionManager.responseSerializer = AFJSONResponseSerializer()



        sessionManager.get("https://affiliate-api.flipkart.net/affiliate/" + endPoint, parameters: nil, success: {
            (task: URLSessionDataTask, responseObject: Any) in
            let map = Map.init(mappingType: MappingType.fromJSON, JSON: responseObject as! [String : Any?])
            let response = FKM_CategoryList(map: map)
            success(response)
            NSLog("Success")

        }, failure: {
            (task: URLSessionDataTask?, error: Error) in
            NSLog("Error")
        })
    }

    func getRequestParams() -> NSDictionary {
        return ["Fk-Affiliate-Id": "iamdonkun", "Fk-Affiliate-Token" : "0097bb5fbf0747549338f328e5a6201a"]
    }
}
