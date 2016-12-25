//
//  AMZSearchResultResponse.swift
//  Piktora
//
//  Created by Kunal Thacker on 12/23/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation

class AMZSearchResultResponse : NSObject, XMLParserDelegate {
    var items : [AmazonItemWithDetails] = []
    
    private var currItems : [AmazonItem] = []
    private var currItemsWithURL : [AmazonItemWithUrl] = []
    
    private var currItem : AmazonItemWithDetails?
    
    private var currItemName : String = ""
    private var currItemASIN : String = ""
    private var currItemURL : String = ""
    private var currItemFormattedPrice : String = ""
    
    private var currElement: String?
    
    var parser = XMLParser()
    var isParsing = false
    
    func initFromXMLResponse(responseObject: Any) {
        if let parser = responseObject as? XMLParser {
            parser.delegate = self
            let _ = parser.parse()
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "Item" {
            self.isParsing = true
            self.currItemName = ""
            self.currItemASIN = ""
            self.currItemURL = ""
            self.currItemFormattedPrice = ""
        }
        
        if elementName == "ASIN" || elementName == "Title" || elementName == "FormattedPrice" {
            self.currElement = elementName
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.isParsing {
            if self.currElement == "Title" {
                self.currItemName.append(string)
            } else if self.currElement == "ASIN" {
                self.currItemASIN.append(string)
            } else if self.currElement == "DetailPageURL" {
                self.currItemURL.append(string)
            } else if self.currElement == "FormattedPrice" {
                self.currItemFormattedPrice.append(string)
            }
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Item"{
            self.currItem = AmazonItemWithDetails(title: self.currItemName, ASIN: self.currItemASIN, imageURL: self.currItemURL, formattedPrice: self.currItemFormattedPrice)
            self.items.append(self.currItem!)
            self.isParsing = false
        }
    }
}
