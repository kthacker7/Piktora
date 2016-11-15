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

    func getCategoryList(endPoint: String, success:@escaping (FKM_CategoryList) -> (), failure: @escaping (Error) -> ()) {

        let params = self.getRequestParams()
        let configs = URLSessionConfiguration.default
        configs.httpAdditionalHeaders = params as? [AnyHashable : Any]

        let sessionManager = AFHTTPSessionManager.init(baseURL: nil, sessionConfiguration: configs)

        sessionManager.requestSerializer = AFJSONRequestSerializer()
        sessionManager.responseSerializer = AFJSONResponseSerializer()

        let urlString = "https://affiliate-api.flipkart.net/affiliate/" + endPoint

        sessionManager.get(urlString, parameters: nil, success: {
            (task: URLSessionDataTask, responseObject: Any) in
            //let  : Array <DString : Any?> = responseObject
            let map = Map.init(mappingType: MappingType.fromJSON, JSON: (responseObject as! NSDictionary) as! [String : Any])
            let response = FKM_CategoryList(map: map)

            NSLog("Success")
            success(response)
        }, failure: {
            (task: URLSessionDataTask?, error: Error) in
            NSLog("Error")
            failure(error)
        })
    }

    func getProducts(urlString: String, success:@escaping (FKM_FeedsResponse) -> (), failure: @escaping (Error) -> ()) {
        let params = self.getRequestParams()
        let configs = URLSessionConfiguration.default
        configs.httpAdditionalHeaders = params as? [AnyHashable : Any]

        let sessionManager = AFHTTPSessionManager.init(baseURL: nil, sessionConfiguration: configs)

        sessionManager.requestSerializer = AFJSONRequestSerializer()
        sessionManager.responseSerializer = AFJSONResponseSerializer()

        // https://affiliate-api.flipkart.net/affiliate/feeds/<your affiliate_tracking_id>/category/<category>.json

        sessionManager.get(urlString, parameters: nil, success: {(dataTask, responseObject: Any) in
            NSLog("Success")
            let map = Map.init(mappingType: MappingType.fromJSON, JSON: (responseObject as! NSDictionary) as! [String : Any])
            let response = FKM_FeedsResponse(map: map)
            success(response)


        }, failure: {(task: URLSessionDataTask?, error: Error) in
            NSLog("Failure")
            failure(error)
        })

    }

    func getRequestParams() -> NSDictionary {
        return ["Fk-Affiliate-Id": "iamdonkun", "Fk-Affiliate-Token" : "0097bb5fbf0747549338f328e5a6201a"]
    }
}
