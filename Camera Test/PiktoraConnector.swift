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
import AWSCore
import Alamofire

class PiktoraConnector {
    static let sharedInstance = PiktoraConnector()
    
    // MARK: Flipkart
    
    struct FKMCategoryListResponseWithTime {
        var time: Date
        var response: FKM_CategoryList
    }
    
    struct FKMFeedsResponseWithTime {
        var time: Date
        var response: FKM_FeedsResponse
    }
    
    var FKMCategoryListResponseCache: [String : FKMCategoryListResponseWithTime] = [:]
    var FKMFeedsResponseCache: [String : FKMFeedsResponseWithTime] = [:]

    func getCategoryList(endPoint: String, success:@escaping (FKM_CategoryList) -> (), failure: @escaping (Error) -> ()) {
        
        if let response = FKMCategoryListResponseCache[endPoint] {
            var time = response.time.timeIntervalSinceNow
            if time < 0 {
                time = time * (-1.0)
            }
            if time <= 3 * 60.0 {
                success(response.response)
                return
            } else {
                let _ = FKMCategoryListResponseCache.removeValue(forKey: endPoint)
            }
        }
        
        let params = self.getRequestParams(website: .FlipKart)
        let configs = URLSessionConfiguration.default
        configs.httpAdditionalHeaders = params

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
            self.FKMCategoryListResponseCache[endPoint] = FKMCategoryListResponseWithTime(time: Date(), response: response)
            success(response)
        }, failure: {
            (task: URLSessionDataTask?, error: Error) in
            NSLog("Error")
            failure(error)
        })
    }

    func getProducts(urlString: String, success:@escaping (FKM_FeedsResponse) -> (), failure: @escaping (Error) -> ()) {
        if let response = FKMFeedsResponseCache[urlString] {
            var time = response.time.timeIntervalSinceNow
            if time < 0 {
                time = time * (-1.0)
            }
            var validTill = 10 * 60.0
            if response.response.validTill != nil {
                validTill = Double(response.response.validTill!)
            }
            if time <= validTill {
                success(response.response)
                return
            } else {
                let _ = FKMFeedsResponseCache.removeValue(forKey: urlString)
            }
        }
        let params = self.getRequestParams(website: .FlipKart)
        let configs = URLSessionConfiguration.default
        configs.httpAdditionalHeaders = params

        let sessionManager = AFHTTPSessionManager.init(baseURL: nil, sessionConfiguration: configs)

        sessionManager.requestSerializer = AFJSONRequestSerializer()
        sessionManager.responseSerializer = AFJSONResponseSerializer()

        // https://affiliate-api.flipkart.net/affiliate/feeds/<your affiliate_tracking_id>/category/<category>.json

        sessionManager.get(urlString, parameters: nil, success: {(dataTask, responseObject: Any) in
            NSLog("Success")
            let map = Map.init(mappingType: MappingType.fromJSON, JSON: (responseObject as! NSDictionary) as! [String : Any])
            let response = FKM_FeedsResponse(map: map)
            self.FKMFeedsResponseCache[urlString] = FKMFeedsResponseWithTime(time: Date(), response: response)
            success(response)
        }, failure: {(task: URLSessionDataTask?, error: Error) in
            NSLog("Failure")
            failure(error)
        })

    }

    func getRequestParams(website: PK_Website) -> [AnyHashable : Any] {
        if website == .FlipKart {
            return ["Fk-Affiliate-Id" : "iamdonkun", "Fk-Affiliate-Token" : "0097bb5fbf0747549338f328e5a6201a"]
        } else {
            return ["AWSAccessKeyId" : "AKIAJWN2JBBX3W62JMZA", "AssociateTag" : "iamdonkun-21", "Service" : "AWSECommerceService"]
        }
    }

    // MARK: Amazon Api
    
    let AWSSecretKey = "iuNcNbf2zxLyDvChzR/yOosqmRuaSva+hmmEWMcA"
    
    struct AMZBrowseNodeResponseWithTime {
        var time: Date
        var response: AMZBrowseNodeResponse
    }
    
    var AMZResponseCache: [Int : AMZBrowseNodeResponseWithTime] = [:]

    func browseNodeLookupForNodeID(nodeID: String, responseGroups: String, success:@escaping (Any) -> (), failure: @escaping (Error) -> ()) {
        let isSearchResults = (responseGroups as NSString).range(of: "MostGifted").location != NSNotFound
        let response = AMZResponseCache[Int(nodeID)!]
        if  response != nil && !isSearchResults {
            var time = response!.time.timeIntervalSinceNow
            if time < 0 {
                time = time * (-1.0)
            }
            if time <= 10 * 60.0 {
                success(response!.response)
                return
            } else {
                let _ = AMZResponseCache.removeValue(forKey: Int(nodeID)!)
            }
        }
        
        let commonParams = NSMutableDictionary(dictionary: self.getRequestParams(website: .Amazon))
        commonParams.setValue("BrowseNodeLookup", forKey: "Operation")
        commonParams.setValue(nodeID, forKey: "BrowseNodeId")
        commonParams.setValue(responseGroups, forKey: "ResponseGroup")
        let characterSet = CharacterSet(charactersIn: ":,").inverted
        let stringFromDate = Date().iso8601.addingPercentEncoding(withAllowedCharacters: characterSet)

        commonParams.setValue(stringFromDate, forKey: "Timestamp")
        let url = self.generateUrlWithSignature(params: commonParams)

        let configs = URLSessionConfiguration.default

        let sessionManager = AFHTTPSessionManager.init(baseURL: nil, sessionConfiguration: configs)
        sessionManager.responseSerializer = AFXMLParserResponseSerializer()
        sessionManager.get(url, parameters: nil, success: {(dataTask, responseObject: Any) in
            NSLog("Success")
            if !isSearchResults {
                let response = AMZBrowseNodeResponse()
                response.initFromXMLResponse(responseObject: responseObject)
                self.AMZResponseCache[Int(nodeID)!] = AMZBrowseNodeResponseWithTime(time: Date(), response: response)
                success(response)
                return
            }
            success(responseObject)
        }, failure: {(task: URLSessionDataTask?, error: Error) in
            NSLog("Failure")
            failure(error)
        })
    }
    
    struct AMZItemLookupResponseWithTime {
        var time: Date
        var response: AMZItemLookupResponse
        var responseGroups : String
    }
    
    var AMZItemCache: [String : AMZItemLookupResponseWithTime] = [:]
    
    func itemLookupForASIN(ASIN: String, responseGroups: String, success:@escaping(Any) -> (), failure: @escaping (Error) -> ()) {
        let response = AMZItemCache[ASIN]
        if  response != nil {
            var time = response!.time.timeIntervalSinceNow
            if time < 0 {
                time = time * (-1.0)
            }
            if time <= 60 * 60.0 {
                if response?.responseGroups == responseGroups {
                    success(response!.response)
                    return
                }
            } else {
                let _ = AMZItemCache.removeValue(forKey: ASIN)
            }
        }
        
        let commonParams = NSMutableDictionary(dictionary: self.getRequestParams(website: .Amazon))
        commonParams.setValue("ItemLookup", forKey: "Operation")
        commonParams.setValue(ASIN, forKey: "ItemId")
        commonParams.setValue(responseGroups, forKey: "ResponseGroup")
        let characterSet = CharacterSet(charactersIn: ":,").inverted
        let stringFromDate = Date().iso8601.addingPercentEncoding(withAllowedCharacters: characterSet)
        
        commonParams.setValue(stringFromDate, forKey: "Timestamp")
        let url = self.generateUrlWithSignature(params: commonParams)
        
        let configs = URLSessionConfiguration.default
        
        let sessionManager = AFHTTPSessionManager.init(baseURL: nil, sessionConfiguration: configs)
        sessionManager.responseSerializer = AFXMLParserResponseSerializer()
        sessionManager.get(url, parameters: nil, success: {(dataTask, responseObject: Any) in
            NSLog("Success")
            
            let response = AMZItemLookupResponse()
            response.ASIN = ASIN
            response.initFromXMLResponse(responseObject: responseObject)
            self.AMZItemCache[ASIN] = AMZItemLookupResponseWithTime(time: Date(), response: response, responseGroups: responseGroups)
            success(response)
        }, failure: {(task: URLSessionDataTask?, error: Error) in
            NSLog("Failure")
            failure(error)
        })
    }
    func generateUrlWithSignature(params: NSMutableDictionary) -> String{

        var keys = params.allKeys as? [String]
        if keys == nil {
            return ""
        }
        keys?.sort(by: { (a, b) -> Bool in
            let bufA = [UInt8](a.utf8)
            let bufB = [UInt8](b.utf8)
            var i = 0
            for aChar in bufA {
                let bChar = bufB[i]
                if bChar < aChar {
                    return false
                } else if aChar < bChar {
                    return true
                }
                i += 1
            }
            return true
        })
        var sortedParamList = "GET\nwebservices.amazon.in\n/onca/xml\n"
        var signedURL = "http://webservices.amazon.in/onca/xml?"
        for key in keys! {
            if let val = params.value(forKey: key) as? String {
                sortedParamList += (key + "=" + val + "&")
                signedURL += (key + "=" + val + "&")
            }
        }
        if sortedParamList[sortedParamList.index(before: sortedParamList.endIndex)] == "&" {
            sortedParamList = String(sortedParamList.characters.dropLast())
        }

        let data = sortedParamList.data(using: String.Encoding.ascii)

        let characterSet = CharacterSet(charactersIn: "+=/").inverted
        if let signature = AWSSignatureSignerUtility.sha256HMac(with: data, withKey: self.AWSSecretKey.data(using: String.Encoding.ascii)).base64EncodedString().addingPercentEncoding(withAllowedCharacters: characterSet) {
            signedURL += "Signature=" + signature
        }
        return signedURL
    }
}

extension Date {
    struct Formatter {
        static let iso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            return formatter
        }()
    }
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}


extension String {
    var dateFromISO8601: Date? {
        return Date.Formatter.iso8601.date(from: self)
    }
}
